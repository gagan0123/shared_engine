#!/bin/bash
echo -n "Enter new username:"
read USERNAME
#Making POOLNAME and GROUPNAME different as it might be needed to change them to different values in future
POOLNAME=$USERNAME
GROUPNAME=$USERNAME
echo -n "Enter domain:"
read DOMAIN
#echo -n "Enter PHP version to use(5.6, 7.0, 7.1):"

source config.sh

#Creating new user and adding www-data to its group so that it can read files
adduser --disabled-password --disabled-login --gecos "$USERNAME" $USERNAME
usermod -a -G $USERNAME www-data
mkdir /home/$USERNAME/$DOMAIN
mkdir /home/$USERNAME/$DOMAIN/htdocs
mkdir /home/$USERNAME/$DOMAIN/logs

#Fixing permissions and owner on the new domain's folder
cd /home/$USERNAME
find ./ -type d -exec chmod 750 {} \;
find ./ -type f -exec chmod 640 {} \;
chown -R -h $USERNAME:$USERNAME /home/$USERNAME

# Creating new FPM Pool for new user
cp /root/tools/shared_engine/templates/php-fpm-pool.conf /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf
sed -i "s/POOLNAME/$POOLNAME/g" /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf
sed -i "s/USERNAME/$USERNAME/g" /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf
sed -i "s/GROUPNAME/$GROUPNAME/g" /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf

# Creating new upstream for new user in nginx
cp /root/tools/shared_engine/templates/nginx-upstream.conf /etc/nginx/conf.d/upstream-$POOLNAME.conf
sed -i "s/POOLNAME/$POOLNAME/g" /etc/nginx/conf.d/upstream-$POOLNAME.conf

#Creating new nginx config for the site
# @todo make option for creation of different types of sites like WordPress or PHP only
cp /root/tools/shared_engine/templates/nginx-php.conf /etc/nginx/sites-available/$DOMAIN
sed -i "s/DOMAINNAME/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/POOLNAME/$POOLNAME/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/USERNAME/$USERNAME/g" /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

ln -s /home/$USERNAME/$DOMAIN /var/www/$DOMAIN
chown -h www-data:www-data /var/www/$DOMAIN

service php$PHPVERSION-fpm reload
service nginx reload

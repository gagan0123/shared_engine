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
adduser --disabled-password --disabled-login --gecos "$USERNAME" --home /var/www/vhosts/$DOMAIN $USERNAME
usermod -a -G $USERNAME www-data
mkdir /var/www/vhosts/$DOMAIN/htdocs
mkdir /var/www/vhosts/$DOMAIN/logs

#Fixing permissions and owner on the new domain's folder
cd /var/www/vhosts/$DOMAIN
find ./ -type d -exec chmod 750 {} \;
find ./ -type f -exec chmod 640 {} \;
chown -R -h $USERNAME:$USERNAME /var/www/vhosts/$DOMAIN

# Creating new FPM Pool for new user
cp /root/tools/shared_engine/templates/php-fpm-pool.conf /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf
sed -i "s/POOLNAME/$POOLNAME/g" /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf
sed -i "s/USERNAME/$USERNAME/g" /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf
sed -i "s/GROUPNAME/$GROUPNAME/g" /etc/php/$PHPVERSION/fpm/pool.d/$POOLNAME.conf

#Creating new nginx config for the site
# @todo make option for creation of different types of sites like WordPress or PHP only
cp /root/tools/shared_engine/templates/nginx-php.conf /etc/nginx/sites-available/$DOMAIN
sed -i "s/DOMAINNAME/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/POOLNAME/$POOLNAME/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/USERNAME/$USERNAME/g" /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

service php$PHPVERSION-fpm reload
service nginx reload

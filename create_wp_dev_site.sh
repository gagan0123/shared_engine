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

#Creating new nginx config for the site
# @todo make option for creation of different types of sites like WordPress or PHP only
HTPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 30 | head -n 1)
htpasswd -bc /etc/nginx/auth/$DOMAIN.htpasswd $USERNAME $HTPASS
certbot certonly --webroot -w /var/www/letsencrypt -d $DOMAIN
cp /root/tools/shared_engine/templates/nginx-dev-php.conf /etc/nginx/sites-available/$DOMAIN
sed -i "s/DOMAINNAME/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/POOLNAME/$POOLNAME/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/USERNAME/$USERNAME/g" /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

ln -s /home/$USERNAME/$DOMAIN /var/www/$DOMAIN
chown -h www-data:www-data /var/www/$DOMAIN

service php$PHPVERSION-fpm reload
service nginx reload


DB_SUFFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
DBNAME=${USERNAME}_$DB_SUFFIX
USER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
DBUSER=${USERNAME}_$USER_SUFFIX
DBPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 30 | head -n 1)
mysql -e "CREATE DATABASE $DBNAME"
mysql -e "CREATE USER $DBUSER@localhost identified with mysql_native_password by '$DBPASS'"
mysql -e "GRANT ALL ON $DBNAME.* TO $DBUSER@localhost"
echo "Database Created"
echo "DB: $DBNAME"
echo "USER: $DBUSER"
echo "PASS: $DBPASS"

WP_PATH="/home/$USERNAME/$DOMAIN/htdocs"
sudo -u $USERNAME wp core download --path=$WP_PATH
sudo -u $USERNAME wp config create --dbname="$DBNAME" --dbuser="$DBUSER" --dbpass="$DBPASS" --path=$WP_PATH --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
PHP

echo "HTTP Auth Credentials:"
echo "Username: $USERNAME"
echo "Password: $HTPASS"

echo "Database Credentials"
echo "DB: $DBNAME"
echo "USER: $DBUSER"
echo "PASS: $DBPASS"
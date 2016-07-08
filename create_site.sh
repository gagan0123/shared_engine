#!/bin/bash
echo -n "Enter new username:"
read USERNAME
echo -n "Enter domain:"
read DOMAIN

#Creating new user and adding www-data to its group so that it can read files
adduser --disabled-password --disabled-login --gecos "$USERNAME" $USERNAME
usermod -a -G $USERNAME www-data
mkdir /home/$USERNAME/$DOMAIN
mkdir /home/$USERNAME/$DOMAIN/htdocs
mkdir /home/$USERNAME/$DOMAIN/logs

cd /home/$USERNAME
find -type d|xargs -I file chmod 750 file
find -type f|xargs -I file chmod 640 file
chown -R $USERNAME:$USERNAME /home/$USERNAME

# Creating new FPM Pool for new user
cp /etc/php5/fpm/pool.d/gagan.conf /etc/php5/fpm/pool.d/$USERNAME.conf
sed -i "s/gagan/$USERNAME/g" /etc/php5/fpm/pool.d/$USERNAME.conf

# Creating new upstream for new user in nginx
cp /etc/nginx/conf.d/upstream-gagan.conf /etc/nginx/conf.d/upstream-$USERNAME.conf
sed -i "s/gagan/$USERNAME/g" /etc/nginx/conf.d/upstream-$USERNAME.conf

cp /etc/nginx/sites-available/template /etc/nginx/sites-available/$DOMAIN
sed -i "s/domainname/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
sed -i "s/user/$USERNAME/g" /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

service php5-fpm reload
service nginx reload

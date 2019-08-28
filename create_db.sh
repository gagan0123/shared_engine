#!/bin/bash
echo -n "New database prefix:"
read DB
DB_SUFFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
DBNAME=${DB}_$DB_SUFFIX
USER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
USERNAME=${DB}_$USER_SUFFIX
DBPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 30 | head -n 1)
mysql -e "CREATE DATABASE $DBNAME"
mysql -e "GRANT ALL ON $DBNAME.* TO $USERNAME@localhost identified by '$(DBPASS)'"
echo "Database Created"
echo "DB: $DBNAME"
echo "USER: $USERNAME"
echo "PASS: $DBPASS"

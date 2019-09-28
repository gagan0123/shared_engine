#!/bin/bash

# Script to create SFTP Users for selected domains

export EXCLUDED_DOMAINS=("html" "letsencrypt")
cd /var/www
export DOMAINS=($(ls -d */ | sed 's#/##'))

# Remove EXCLUDED_DOMAINS from DOMAINS array
for target in "${EXCLUDED_DOMAINS[@]}"; do
  for i in "${!DOMAINS[@]}"; do
    if [[ ${DOMAINS[i]} == $target ]]; then
      unset 'DOMAINS[i]'
    fi
  done
done

echo "Select the domain for SFTP User:"
select SELECTED in "${DOMAINS[@]}"
do
	OWNER=$(stat -L -c "%U" /var/www/$SELECTED)
	OWNER_ID=$(id -u $OWNER)
	GROUP=$(stat -L -c "%G" /var/www/$SELECTED)
	GROUP_ID=$(getent group $GROUP | cut -d: -f3)
	REAL_PATH_OF_DOMAIN=$(readlink /var/www/$SELECTED)
	echo "$SELECTED is owned by User:$OWNER($OWNER_ID) Group:$GROUP($GROUP_ID) and real path is $REAL_PATH_OF_DOMAIN"
	echo "Enter Username:"
	read USERNAME
	FULL_USERNAME="${OWNER}_${USERNAME}"
	PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 30 | head -n 1)
	PASSWORD_ENCRYPTED=$(openssl passwd -1 $PASSWORD)
	useradd -d $REAL_PATH_OF_DOMAIN -s /bin/false -o -u $OWNER_ID -g $GROUP_ID -p $PASSWORD_ENCRYPTED $FULL_USERNAME
	usermod -a -G sftponly $FULL_USERNAME 
	echo "User: $FULL_USERNAME"
	echo "Pass: $PASSWORD"
	break
done

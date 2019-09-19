#!/bin/bash
source config.sh
echo "Enter domain:"
read DOMAIN
cd /etc/opendkim/keys/
mkdir "$DOMAIN"
cd "$DOMAIN"
opendkim-genkey -t -s "$DKIM_SELECTOR" -d "$DOMAIN"
chown -R opendkim:opendkim .

echo "${DKIM_SELECTOR}._domainkey.${DOMAIN} ${DOMAIN}:${DKIM_SELECTOR}:/etc/opendkim/keys/${DOMAIN}/${DKIM_SELECTOR}.private" >> /etc/opendkim/KeyTable

echo "*@${DOMAIN} ${DKIM_SELECTOR}._domainkey.${DOMAIN}" >> /etc/opendkim/SigningTable

service opendkim reload

cat /etc/opendkim/keys/${DOMAIN}/${DKIM_SELECTOR}.txt

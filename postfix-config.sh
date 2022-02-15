#!/bin/bash

#Install the authentication library
apt install libsasl2-modules

#Configure our API key for login
echo "[smtp.sendgrid.net]:587 apikey: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" > /etc/postfix/sasl_passwd

#Stored hashed API key into database
postmap hash:/etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd

#Backup and overwrite main.cf configuration file
cp /etc/postfix/main.cf /etc/postfix/main.cf.backup 
cp --force /root/pve-tools/postfix-files/main.cf /etc/postfix/

#Overwrite sender ID
echo "/.+/    support@weidmarkit.com" > /etc/postfix/sender_canonical_maps
#Overwrite header ID
echo "/From:.*/ REPLACE From: support@weidmarkit.com" > /etc/postfix/header_check
#Reload postfix
postfix reload

#Install library if using proxmox backup server
if [ -x "$(command -v proxmox-backup-client)" ] ; then
    apt install bsd-mailx
fi 

echo "test message" | mail -s "test subject" support@weidmarkit.com
echo "Test message sent to support@weidmarkit.com"
#!/bin/bash

#Install the authentication library
apt install libsasl2-modules -y

#Configure our API key for login
echo "INSERT SENDGRID KEY HERE AND DO NOT PUSH IT TO ORIGIN . . . EVER" > /etc/postfix/sasl_passwd

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
    apt install bsd-mailx -y
fi

#You have mail
echo "test message" | mail -s "test subject" support@weidmarkit.com
echo "Test message sent to support@weidmarkit.com"

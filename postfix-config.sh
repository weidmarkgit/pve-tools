#!/bin/bash
CLIENT_EMAIL=""

function initial-configuration(){
  local -r client_password
  read -r -p "Please enter client email: " CLIENT_EMAIL
  read -r -s -p "Please enter client password: " client_password

  #Install the authentication library
  apt install libsasl2-modules bsd-mailx -y

  #Create password file
  echo "[box.weidmark.support]:465 ${CLIENT_EMAIL}:${client_password}" > /etc/postfix/sasl_passwd

  #Stored hashed API key into database
  postmap hash:/etc/postfix/sasl_passwd
  chmod 600 /etc/postfix/sasl_passwd

  #Backup and overwrite main.cf configuration file
  cp /etc/postfix/main.cf /etc/postfix/main.cf.backup
  cp --force /root/pve-tools/postfix-files/main.cf /etc/postfix/
}

function id-configuration() {
  sed -i '/postmaster: root/c\postmaster: ${CLIENT_EMAIL}' /etc/aliases
  #Overwrite sender ID
  echo "/.+/    ${CLIENT_EMAIL}" > /etc/postfix/sender_canonical_maps
  #Overwrite header ID
  echo "/From:.*/ REPLACE From: ${CLIENT_EMAIL}" > /etc/postfix/header_check
  #Reload postfix
  postfix reload
}
function test-email(){
  #You have mail
  echo "test message" | mail -s "testing ${CLIENT_EMAIL}" support@weidmarkit.com
  echo "Test message sent to support@weidmarkit.com"
}

initial-configuration
id-configuration
test-email

finish() {
  result=$?
    printf "postfixconfig.sh completed succesfully\n Please reboot your system to complete configuration\n"
  exit ${result}
}
trap finish EXIT ERR

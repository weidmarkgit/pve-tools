#!/bin/bash

SOURCES=/etc/apt/sources.list 
PVE_ENTERPRISE=/etc/apt/sources.list.d/pve-enterprise.list
PBS_ENTERPRISE=/etc/apt/sources.list.d/pbs-enterprise.list


#Check for APT sources file
if test -f "$SOURCES"; then
    rm -rfv $SOURCES
else
    echo "$SOURCES does not exist"
fi

#Check for Proxmox VE enterprise repository file
if test -f "$PVE_ENTERPRISE"; then
    echo "$PVE_ENTERPRISE exists and and will be removed"
    rm -rfv $PVE_ENTERPRISE
else
    echo "#PVE_ENTERPRISE does not exist"
fi

#Check for Proxmox Backup enterprise repository file
if test -f "$PBS_ENTERPRISE"; then
    echo "$PBS_ENTERPRISE exists and and will be removed"
    rm -rfv $PBS_ENTERPRISE
else
    echo "$PBS_ENTERPRISE does not exist"
fi

#Create new APT source list
echo -e 
"deb http://ftp.debian.org/debian bullseye main contrib\n
deb http://ftp.debian.org/debian bullseye-updates main contrib\n

# PBS pbs-no-subscription repository provided by proxmox.com,\n
# NOT recommended for production use\n
deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription\n

# security updates\n
deb http://security.debian.org/debian-security bullseye-security main contrib\n" 

>> /etc/apt/sources.list 

#Adding fake enterprise repository
wget https://github.com/Jamesits/pve-fake-subscription/releases/download/v0.0.7/pve-fake-subscription_0.0.7_all.deb
dpkg -i pve-fake-subscription_0.0.7_all.deb
echo "127.0.0.1 shop.maurer-it.com" | tee -a /etc/hosts
rm pve-fake-subscription_0.0.7_all.deb

#Final touches
apt update
apt upgrade
pveam update  
reboot

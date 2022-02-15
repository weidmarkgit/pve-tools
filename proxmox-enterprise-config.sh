#!/bin/bash

SOURCES=/etc/apt/sources.list 
PVE_ENTERPRISE=/etc/apt/sources.list.d/pve-enterprise.list
PBS_ENTERPRISE=/etc/apt/sources.list.d/pbs-enterprise.list

IS_PBS=false
IS_PVE=false


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
    $IS_PVE=true
else
    echo "#PVE_ENTERPRISE does not exist"
fi

#Check for Proxmox Backup enterprise repository file
if test -f "$PBS_ENTERPRISE"; then
    echo "$PBS_ENTERPRISE exists and and will be removed"
    rm -rfv $PBS_ENTERPRISE
    $IS_PBS=true
else
    echo "$PBS_ENTERPRISE does not exist"
fi

#Create new APT source list
cp /root/pve-tools/sources.list /etc/apt/

#Adding fake enterprise repository
wget https://github.com/Jamesits/pve-fake-subscription/releases/download/v0.0.7/pve-fake-subscription_0.0.7_all.deb
dpkg -i pve-fake-subscription_0.0.7_all.deb
echo "127.0.0.1 shop.maurer-it.com" | tee -a /etc/hosts
rm pve-fake-subscription_0.0.7_all.deb

#Final touches
apt update
apt upgrade -y

if $IS_PVE; then 
    pveam update
fi

reboot

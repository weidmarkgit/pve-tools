#!/bin/bash
IS_PBS=false
IS_PVE=false

function detect-version() {
    
    # Checks for enterprise repository source list
    # Deletes the enterprise repostiory source list
    # Detects version based on repository source list generated

    local -r  pve_enterprise=/etc/apt/sources.list.d/pve-enterprise.list
    local -r  pbs_enterprise=/etc/apt/sources.list.d/pbs-enterprise.list

    #Check for Proxmox VE enterprise repository file

    if [ -x "$(command pveversion)" ]; then 
        IS_PVE=true
        if test -f "${pve_enterprise}"; then
            rm --recursive --force --verbose ${pve_enterprise}
        else
            echo "${pve_enterprise} does not exist"
        fi 
    fi 
    
    if [ -x "$(command proxmox-backup-client)" ] ; then
        IS_PBS=true
        #Check for Proxmox Backup enterprise repository file
        if test -f "${pbs_enterprise}"; then
            rm --recursive --force --verbose ${pbs_enterprise}
        else
            echo "${pbs_enterprise} does not exist"
        fi
    fi 
}

function configure-sources() {

    # Removes default source list
    # Replaces source list based on Proxmox installation
    local -r  sources=/etc/apt/sources.list 
    local -r  custom_pbs=/root/pve-tools/custom-sources/pbs-sources.list
    local -r  custom_pve=/root/pve-tools/custom-sources/pve-sources.list

    #Check for APT sources file
    if test -f "${sources}"; then
        rm --recursive --force --verbose ${sources}
    else
        echo "${sources} does not exist"
    fi

    if ${IS_PBS}; then
        cp ${custom_pbs} /etc/apt/
        mv /etc/apt/pbs-sources.list /etc/apt/sources.list 
    elif ${IS_PVE}; then 
        cp ${custom_pve} /etc/apt/
        mv /etc/apt/pve-sources.list /etc/apt/sources.list
    else 
        printf "####\n## Unable to determine Proxmox installation type\n####\n" 
    fi 

}

function configure-placeholder-subscription() {

    local -r placeholder_subscription_url=https://github.com/Jamesits/pve-fake-subscription/releases/download/v0.0.7/pve-fake-subscription_0.0.7_all.deb
    
    wget ${placeholder_subscription_url}
    dpkg -i pve-fake-subscription_0.0.7_all.deb
    echo "127.0.0.1 shop.maurer-it.com" | tee -a /etc/hosts
    rm pve-fake-subscription_0.0.7_all.deb

}

# Function calls
detect-version
configure-sources
configure-placeholder-subscription

apt update
apt upgrade -y

if ${IS_PVE}; then 
    pveam update
fi

finish() {
  result=$?
    printf "proxmox-enterprise-config.sh completed succesfully\n Please reboot your system to complete configuration\n"
  exit ${result}
}
trap finish EXIT ERR

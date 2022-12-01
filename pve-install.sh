#!/bin/bash

# Create a 4GB swap file if no swap in fstab
if [ $(cat /etc/fstab | grep -c swap) -eq 0 ]; then
    swapgb=4
    dd if=/dev/zero of=/mnt/${swapgb}GB.swap bs=1024 count=$(expr ${swapgb} \* 1024 \* 1024)
    chmod 600 /mnt/${swapgb}GB.swap
    mkswap /mnt/${swapgb}GB.swap
    swapon /mnt/${swapgb}GB.swap
    cp /etc/fstab ~/fstab.backup
    echo "/mnt/${swapgb}GB.swap swap swap defaults 0 0" | tee -a /etc/fstab
fi

if [ $(cat /etc/sysctl.d/90-swappiness.conf | grep -c "vm.swappiness = 10") -eq 0 ]; then
    echo "vm.swappiness = 10" | tee /etc/sysctl.d/99-swappiness.conf
fi

# Change to regular updates
rm /etc/apt/sources.list.d/pve-enterprise.list
rm /etc/apt/sources.list.d/pve-no-subscription.list

cat << EOF >> /etc/apt/sources.list.d/pve-no-subscription.list
# PVE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF


apt autoremove
apt autoclean
apt update
apt install unattended-upgrades apt-listchanges -y # Install unattended-upgrades to automatically install updates
dpkg-reconfigure -plow unattended-upgrades # Configure it
apt upgrade -y # Update everything first


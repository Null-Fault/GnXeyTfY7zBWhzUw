#!/bin/bash

# Add to sudo group and reboot for safe measure
if [ $(groups $(whoami)| grep -c sudo) -eq 0 ]; then
su -l -c "apt update && apt install sudo && adduser $(whoami) sudo && reboot now"
fi

# Create a 4GB swap file if no swap in fstab
if [ $(cat /etc/fstab | grep -c swap) -eq 0 ]; then
swapgb=4
sudo dd if=/dev/zero of=/mnt/${swapgb}GB.swap bs=1024 count=$(expr ${swapgb} \* 1024 \* 1024)
sudo chmod 600 /mnt/${swapgb}GB.swap
sudo mkswap /mnt/${swapgb}GB.swap
sudo swapon /mnt/${swapgb}GB.swap
sudo cp /etc/fstab ~/fstab.backup
echo "/mnt/${swapgb}GB.swap swap swap defaults 0 0" | sudo tee -a /etc/fstab
fi

if [ $(cat /etc/sysctl.d/90-swappiness.conf | grep -c "vm.swappiness = 10") -eq 0 ]; then
echo "vm.swappiness = 10" | sudo tee /etc/sysctl.d/99-swappiness.conf
fi

sudo apt purge libreoffice*
sudo apt autoremove
sudo apt autoclean
sudo apt update
sudo apt upgrade -y # Update everything first
sudo apt install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

# VMware Tools
sudo apt install open-vm-tools
sudo apt install open-vm-tools-desktop

# Application installs
sudo apt install keepassxc
sudo apt install gnome-tweaks
sudo apt install vlc
sudo apt install git

#VS Code
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/vscode.deb
sudo apt install /tmp/vscode.deb
rm /tmp/vscode.deb

#Google Chrome
wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O /tmp/chrome.deb
sudo apt install /tmp/chrome.deb
rm /tmp/chrome.deb

#Parsec Remote
wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O /tmp/parsec.deb
sudo apt install /tmp/parsec.deb
rm /tmp/parsec.deb

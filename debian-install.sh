#!/bin/bash

#iamwho=${whoami}
sudogroupcheck="$(groups | grep -c sudo)" 
if [ $(groups $(whoami)| grep -c sudo) -eq 0 ]; then
# su -l -c "adduser $iamwho -G sudo && reboot now" # Run if not a sudoer 
su -l -c "adduser $(whoami) sudo" # && reboot now"
fi

swapgb=4
sudo dd if=/dev/zero of=/mnt/${swapgb}GB.swap bs=1024 count=$(expr ${swapgb} \* 1024 \* 1024)
sudo chmod 600 /mnt/${swapgb}GB.swap
sudo mkswap /mnt/${swapgb}GB.swap
sudo swapon /mnt/${swapgb}GB.swap
sudo cp /etc/fstab ~/fstab.backup
echo "/mnt/${SWAPGB}GB.swap swap swap defaults 0 0" | sudo tee -a /etc/fstab

sudo apt update && sudo apt upgrade -y # Update everything first
sudo apt install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

# VMware Tools
sudo apt install open-vm-tools
sudo apt install open-vm-tools-desktop

# Application installs
sudo apt install git
sudo apt install vlc
sudo apt install keepassxc
sudo apt install gnome-tweaks

wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O /tmp/chrome.deb
sudo apt install /tmp/chrome.deb
rm /tmp/chrome.deb

wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/vscode.deb
sudo apt install /tmp/vscode.deb
rm /tmp/vscode.deb

wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O /tmp/parsec.deb
sudo apt install ./parsec.deb
rm /tmp/parsec.deb

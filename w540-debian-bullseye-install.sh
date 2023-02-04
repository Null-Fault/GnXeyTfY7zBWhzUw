#!/bin/bash
sudo apt update && sudo apt -y upgrade

# Add to sudo group and reboot for safe measure
if [ $(groups $(whoami)| grep -c sudo) -eq 0 ]; then
  su -l -c "apt -y update && apt -y install sudo && adduser $(whoami) sudo && reboot now"
fi

sudo rm /etc/apt/sources.list
cat << EOF | sudo tee /etc/apt/sources.list
deb http://deb.debian.org/debian/ bullseye main non-free contrib
deb-src http://deb.debian.org/debian/ bullseye main non-free contrib

deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free

# bullseye-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free

# Backports
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF

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

# Put tmp on tmpfs
echo "tmpfs /tmp tmpfs defaults 0 0" | sudo tee -a /etc/fstab

if [ $(cat /etc/sysctl.d/99-swappiness.conf | grep -c "vm.swappiness = 1") -eq 0 ]; then
  echo "vm.swappiness = 1" | sudo tee /etc/sysctl.d/99-swappiness.conf
fi

# Remove libreoffice and gnome-games
sudo apt -y purge libreoffice*
sudo apt -y purge gnome-games
sudo apt -y autoremove
sudo apt -y autoclean

# Update everything first
sudo dpkg --add-architecture i386 # For Steam
sudo apt -y update
sudo apt -y upgrade 
# sudo apt -y install qemu-guest-agent
sudo apt -y install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

# Linux headers
sudo apt -y install linux-headers-$(dpkg --print-architecture)

# Application installs
sudo apt -y install gnome-tweaks
sudo apt -y install gnome-shell-extension-dashtodock
sudo apt -y install keepassxc
sudo apt -y install vlc
sudo apt -y install git

#VS Code
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/vscode.deb
sudo apt -y install /tmp/vscode.deb
rm /tmp/vscode.deb

#Google Chrome
wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O /tmp/chrome.deb
sudo apt -y install /tmp/chrome.deb
rm /tmp/chrome.deb

#Parsec Remote
wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O /tmp/parsec.deb
sudo apt -y install /tmp/parsec.deb
rm /tmp/parsec.deb


# w540 specific
sudo apt -y install nvidia-driver firmware-misc-nonfree

# Steam
sudo apt -y install steam
sudo apt -y install mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

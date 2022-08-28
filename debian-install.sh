SWAPGB=4
sudo dd if=/dev/zero of=/mnt/${SWAPGB}GB.swap bs=1024 count=$(expr ${SWAPGB} \* 1024 \* 1024)
sudo chmod 600 /mnt/${SWAPGB}GB.swap
sudo mkswap /mnt/${SWAPGB}GB.swap
sudo swapon /mnt/${SWAPGB}GB.swap
sudo cp /etc/fstab ~/fstab.backup
echo "/mnt/${SWAPGB}GB.swap swap swap defaults 0 0" | sudo tee -a /etc/fstab

sudo apt update && sudo apt upgrade -y # Update everything first
sudo apt install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

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

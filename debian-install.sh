SWAPGB=4
sudo dd if=/dev/zero of=/mnt/${SWAPGB}GB.swap bs=1024 count=$(expr ${SWAPGB} \* 1024 \* 1024)
sudo chmod 600 /mnt/${SWAPGB}GB.swap
sudo mkswap /mnt/${SWAPGB}GB.swap
sudo swapon /mnt/${SWAPGB}GB.swap
echo "/mnt/${SWAPGB}GB.swap swap swap defaults 0 0" | sudo tee -a /etc/fstab

sudo apt update && sudo apt upgrade -y # Update everything first
sudo apt install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

# Application installs
sudo apt install vlc
sudo apt install keepassxc
sudo apt install gnome-tweaks

wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O chrome.deb
sudo apt install ./chrome.deb
rm ./chrome.deb

wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O vscode.deb
sudo apt install ./vscode.deb
rm ./vscode.deb

wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O parsec.deb
sudo apt install ./parsec.deb
rm ./parsec.deb

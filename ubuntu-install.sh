if [ $(cat /etc/sysctl.d/99-swappiness.conf | grep -c "vm.swappiness = 1") -eq 0 ]; then
echo "vm.swappiness = 1" | sudo tee /etc/sysctl.d/99-swappiness.conf
fi

sudo apt -y update
sudo apt -y upgrade # Upgrade everything first
sudo apt -y autoremove
sudo apt -y autoclean
sudo apt -y install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

#sudo apt -y install vlc
#sudo apt -y install keepassxc
#sudo apt -y install steam
#sudo apt install gnome-tweaks

wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O chrome.deb
sudo apt install ./chrome.deb
rm ./chrome.deb

wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O vscode.deb
sudo apt install ./vscode.deb
rm ./vscode.deb

wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O parsec.deb
sudo apt install ./parsec.deb
rm ./parsec.deb

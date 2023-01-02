apt -y update
apt -y upgrade # Update everything first
apt -y install unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
dpkg-reconfigure -plow unattended-upgrades
apt -y autoremove
apt -y autoclean

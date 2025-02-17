echo AutomaticUpdatePolicy=apply | sudo tee -a /etc/rpm-ostreed.conf
sudo rpm-ostree reload
sudo systemctl edit --force --full rpm-ostreed-automatic.timer # Change to however many days
sudo systemctl enable rpm-ostreed-automatic.timer --now
rpm-ostree kargs --delete-if-present='$ignition_firstboot'
rpm-ostree status

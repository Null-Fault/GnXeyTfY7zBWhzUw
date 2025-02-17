# Install qemu-guest-agent
rpm-ostree install --allow-inactive --assumeyes --reboot qemu-guest-agent
# Configure auto uopdates
echo AutomaticUpdatePolicy=apply | sudo tee -a /etc/rpm-ostreed.conf
sudo rpm-ostree reload
sudo systemctl edit --force --full rpm-ostreed-automatic.timer # Change to however many days
sudo systemctl enable rpm-ostreed-automatic.timer --now
# Disable zezere
rpm-ostree kargs --delete-if-present='$ignition_firstboot' # https://github.com/fedora-iot/iot-distro/issues/14
systemctl disable zezere_ignition.timer --now

rpm-ostree status

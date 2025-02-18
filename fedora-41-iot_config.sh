rpm-ostree upgrade --reboot
rpm-ostree install --allow-inactive --assumeyes --reboot qemu-guest-agent
# Prompt user for the desired hostname
read -p "Enter the desired hostname: " hostname
# Set the hostname
hostnamectl set-hostname "$hostname"
echo "Hostname set to $hostname"
# Configure auto uopdates
echo AutomaticUpdatePolicy=apply | tee -a /etc/rpm-ostreed.conf
rpm-ostree reload
systemctl edit --force --full rpm-ostreed-automatic.timer # Change to however many days
systemctl enable rpm-ostreed-automatic.timer --now
# Disable zezere
rpm-ostree kargs --delete-if-present='$ignition_firstboot' # https://github.com/fedora-iot/iot-distro/issues/14
systemctl disable zezere_ignition.timer --now

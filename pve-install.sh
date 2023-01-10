#!/bin/bash

echo "tmpfs /tmp tmpfs defaults 0 0" | tee -a /etc/fstab

# Create a 4GB swap file if no swap in fstab
# Don't use with ZFS!
if [ $(cat /etc/fstab | grep -c swap) -eq 0 ]; then
    swapgb=4
    dd if=/dev/zero of=/mnt/${swapgb}GB.swap bs=1024 count=$(expr ${swapgb} \* 1024 \* 1024)
    chmod 600 /mnt/${swapgb}GB.swap
    mkswap /mnt/${swapgb}GB.swap
    swapon /mnt/${swapgb}GB.swap
    cp /etc/fstab ~/fstab.backup
    echo "/mnt/${swapgb}GB.swap swap swap defaults 0 0" | tee -a /etc/fstab
fi

# Don't use with ZFS!
if [ $(cat /etc/sysctl.d/90-swappiness.conf | grep -c "vm.swappiness = 10") -eq 0 ]; then
    echo "vm.swappiness = 10" | tee /etc/sysctl.d/99-swappiness.conf
fi

# Change to regular updates
rm /etc/apt/sources.list.d/pve-enterprise.list
rm /etc/apt/sources.list.d/pve-no-subscription.list

cat << EOF >> /etc/apt/sources.list.d/pve-no-subscription.list
# PVE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF

apt autoremove
apt autoclean
apt update
apt install gcc make pve-headers -y
apt install unattended-upgrades apt-listchanges -y # Install unattended-upgrades to automatically install updates
dpkg-reconfigure -plow unattended-upgrades # Configure it
apt upgrade -y # Update everything first

# K1100M specific
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/470.161.03/NVIDIA-Linux-x86_64-470.161.03.run

# Disable nouveau driver, just copying exactly what the Nvidia installer would make
cat << EOF >> /etc/modprobe.d/nvidia-installer-disable-nouveau.conf
# generated by nvidia-installer
blacklist nouveau
options nouveau modeset=0
EOF

reboot now

sh NVIDIA-Linux-x86_64-470.161.03.run # Use default options

cat << EOF >> /etc/modules-load.d/modules.conf
# Nvidia modules
nvidia
nvidia_uvm
EOF

cat << EOF >> /etc/udev/rules.d/70-nvidia.rules
KERNEL=="nvidia", RUN+="/bin/bash -c '/usr/bin/nvidia-smi -L && /bin/chmod 666 /dev/nvidia*'"
KERNEL=="nvidia_uvm", RUN+="/bin/bash -c '/usr/bin/nvidia-modprobe -c0 -u && /bin/chmod 0666 /dev/nvidia-uvm*'"
EOF

update-initramfs -u -k all

reboot now


# Obtain numbers for lxc.cgroup.devices.allow from ls -l /dev/nvidia*

cat << EOF >> /some/path/to/lxc/container/config # CHANGE THIS FILE PATH TO PATH OF LXC CONTAINER
# Allow cgroup access
lxc.cgroup.devices.allow: c 195:* rwm
lxc.cgroup.devices.allow: c 234:* rwm

# Pass through device files
lxc.mount.entry: /dev/nvidia0 dev/nvidia0 none bind,optional,create=file
lxc.mount.entry: /dev/nvidiactl dev/nvidiactl none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm dev/nvidia-uvm none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-modeset dev/nvidia-modeset none bind,optional,create=file
lxc.mount.entry: /dev/nvidia-uvm-tools dev/nvidia-uvm-tools none bind,optional,create=file
EOF

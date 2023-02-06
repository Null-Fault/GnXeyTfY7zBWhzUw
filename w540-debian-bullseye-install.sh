#!/bin/bash
sudo apt update && sudo apt upgrade -y

# Add to sudo group and reboot for safe measure
if [ $(groups $(whoami)| grep -c sudo) -eq 0 ]; then
  echo -e "Login as root to install sudo and add your current user to sudo.\nPlease run the script again after reboot.\n"
  read -p "Press [Enter] key to continue..."
  su -l -c "apt update -y && apt install -y sudo && adduser $(whoami) sudo && reboot now "
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
sudo apt purge -y libreoffice*
sudo apt purge -y gnome-games
sudo apt autoremove -y
sudo apt autoclean -y

# Update everything first
sudo dpkg --add-architecture i386 # For Steam
sudo apt update -y
sudo apt upgrade -y 
# sudo apt install -y qemu-guest-agent
sudo apt install -y unattended-upgrades apt-listchanges # Install unattended-upgrades to automatically install updates
sudo dpkg-reconfigure -plow unattended-upgrades # Configure it

# Linux headers
sudo apt install -y linux-headers-$(dpkg --print-architecture)

# Application installs
sudo apt install -y gnome-tweaks
sudo apt install -y gnome-shell-extension-dashtodock
sudo apt install -y keepassxc
sudo apt install -y vlc
sudo apt install -y git

# Microsoft Powershell and VSCode
sudo apt install -y curl gnupg apt-transport-https

# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Register the Microsoft repo
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
# Register the VS Code repo
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update -y
sudo apt install -y code
sudo apt install -y powershell

#Google Chrome
wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' -O /tmp/chrome.deb
sudo apt install -y /tmp/chrome.deb
rm /tmp/chrome.deb

#Parsec Remote
wget 'https://builds.parsecgaming.com/package/parsec-linux.deb' -O /tmp/parsec.deb
sudo apt install -y /tmp/parsec.deb
rm /tmp/parsec.deb

# w540 specific
# Install Nvidia GPU
sudo apt install -y nvidia-driver firmware-misc-nonfree

# For glxinfo and glxgears for testing GPU
sudo apt install -y mesa-utils

# Remove intel xorg package
sudo apt remove -y xserver-xorg-video-intel

# Fixes screen tearing
echo "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
sudo update-initramfs -u

# Auto set max performance mode since it stutters without it (GpuPowerMizerMode=2 (consistent performance) also seems like it may be okay)
cat << EOF | tee ~/.config/autostart/nvidia-powermizer.desktop
[Desktop Entry]
Type=Application
Name=Set Nvidia GpuPowerMizerMode
Exec=nvidia-settings -a [gpu:0]/GpuPowerMizerMode=1
EOF

# https://wiki.debian.org/NVIDIA%20Optimus#Using_NVIDIA_GPU_as_the_primary_GPU
# Configure X11 for only Nvidia GPU to be used (disable Optimus) as it provides a much better docked workstation experience.
cat << EOF | sudo tee /etc/X11/xorg.conf
Section "ServerLayout"
    Identifier "layout"
    Screen 0 "nvidia"
    Inactive "intel"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    BusID "PCI:1:0:0"
EndSection

Section "Screen"
    Identifier "nvidia"
    Device "nvidia"
    Option "AllowEmptyInitialConfiguration"
    #Option "UseDisplayDevice" "none"
EndSection

Section "Device"
    Identifier "intel"
    Driver "modesetting"
    BusID "PCI:0:2:0"
    Option "AccelMethod"  "none"
    #Option "TearFree" "True"
    #Option "Tiling" "True"
    #Option "SwapbuffersWait" "True"
EndSection

Section "Screen"
    Identifier "intel"
    Device "intel"
EndSection
EOF

cat << EOF | tee ~/.xsessionrc:
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
xrandr --dpi 96
EOF
chmod +x ~/.xsessionrc

# Gnome Display Manager configuration
cat << EOF | sudo tee /usr/share/gdm/greeter/autostart/optimus.desktop
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF

# Steam
sudo dpkg --add-architecture i386
sudo apt install -y steam
sudo apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

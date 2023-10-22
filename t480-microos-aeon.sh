sudo zypper refresh && \
sudo transactional-update -i pkg install openSUSE-repos-NVIDIA && \
systemctl reboot

sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA && \
sudo zypper refresh && \
sudo transactional-update -i pkg in nvidia-drivers-G06 && \
systemctl reboot

# sudo prime-select boot nvidia && \ # This is for Optimus laptops to only use Nvidia
sudo setsebool -P selinuxuser_execstack 1 && \
systemctl reboot

sudo transactional-update 
systemctl reboot
sudo transactional-update -i pkg install openSUSE-repos-NVIDIA
systemctl reboot
sudo transactional-update -i pkg install nvidia-drivers-G06
systemctl reboot
sudo prime-select boot offload
systemctl reboot
# prime-run nvidia-settings # Can test if it is working after with this

flatpak install flathub com.google.Chrome
flatpak install flathub org.keepassxc.KeePassXC
flatpak install flathub com.github.iwalton3.jellyfin-media-player
flatpak install flathub com.github.tchx84.Flatseal
flatpak install flathub com.visualstudio.code
flatpak install flathub com.valvesoftware.Steam
flatpak override --user --device=dri --env=__NV_PRIME_RENDER_OFFLOAD=1 --env=__VK_LAYER_NV_optimus=NVIDIA_only --env=__GLX_VENDOR_LIBRARY_NAME=nvidia com.valvesoftware.Steam

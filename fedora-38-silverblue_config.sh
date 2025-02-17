# Upgrade ostree
rpm-ostree upgrade --reboot

# Update flatpaks
flatpak update -y

# Install new flatpaks
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.google.Chrome
flatpak install flathub org.keepassxc.KeePassXC
flatpak install flathub com.github.tchx84.Flatseal
flatpak install flathub com.visualstudio.code
flatpak install flathub com.visualstudio.code.tool.podman

# flatpak install flathub com.valvesoftware.Steam
# flatpak install flathub com.github.iwalton3.jellyfin-media-player

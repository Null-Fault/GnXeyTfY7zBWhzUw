# Install Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Set default packaging preference to Flathubt
gsettings set org.gnome.software packaging-format-preference "['flatpak:flathub', 'flatpak', 'rpm']"t

# Update flatpaks
flatpak update -y

# Upgrade ostree
rpm-ostree upgrade --reboot

# Install Distrobox because it's better than Toolbox
# Layering isn't recommened but it's best if distrobox is layered
rpm-ostree install distrobox

# # Install qemu-guest-agent
# rpm-ostree install --allow-inactive --assumeyes --reboot qemu-guest-agent


# Install new flatpaks
# flatpak install flathub org.mozilla.firefox
# flatpak install flathub com.google.Chrome
# flatpak install flathub org.keepassxc.KeePassXC
# flatpak install flathub com.github.tchx84.Flatseal
# flatpak install flathub com.visualstudio.code
# flatpak install flathub com.visualstudio.code.tool.podman

# flatpak install flathub com.valvesoftware.Steam
# flatpak install flathub com.github.iwalton3.jellyfin-media-player

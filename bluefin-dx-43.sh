# Bluefin default Gnome scaling
# org.gnome.mutter experimental-features ['scale-monitor-framebuffer', 'xwayland-native-scaling']
# To set back
# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']"
# Remove Gnome scaling for better compatibility
gsettings set org.gnome.mutter experimental-features "[]"

# Flatpaks

# Install Steam
flatpak install flathub com.valvesoftware.Steam
flatpak install flathub com.valvesoftware.Steam.CompatibilityTool.Proton-GE
flatpak install flathub org.freedesktop.Platform.VulkanLayer.gamescope
flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud
# Install RetroDeck
flatpak install flathub net.retrodeck.retrodeck
# This is so Steam can start RetroDeck
flatpak override --user --talk-name=org.freedesktop.Flatpak com.valvesoftware.Steam
# This improves startup
flatpak override --user --system-talk-name=org.freedesktop.NetworkManager com.valvesoftware.Steam

# flatpak override --user --talk-name=org.freedesktop.Flatpak net.retrodeck.retrodeck
# RetroDeck can add itself to Steam
# However the shortcut doesn't work
# Change it to:
# Target: /usr/bin/flatpak-spawn
# Launch Options: --host flatpak run net.retrodeck.retrodeck

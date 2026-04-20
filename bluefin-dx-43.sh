# Bluefin default Gnome scaling
# org.gnome.mutter experimental-features ['scale-monitor-framebuffer', 'xwayland-native-scaling']
# To set back
# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']"
# Remove Gnome scaling for better compatibility
gsettings set org.gnome.mutter experimental-features "[]"

# Flatpaks

# Install Steam
flatpak install -y flathub com.valvesoftware.Steam
SDK=$(flatpak info --show-metadata "com.valvesoftware.Steam"  | grep '^sdk=')
# e.g. sdk=org.freedesktop.Sdk/x86_64/25.08
RUNTIME=$(echo "$SDK" | sed 's|[^/]*/||')
# e.g x86_64/25.08
flatpak install -y flathub com.valvesoftware.Steam.CompatibilityTool.Proton-GE
flatpak install -y flathub "org.freedesktop.Platform.VulkanLayer.gamescope/$RUNTIME"
flatpak install -y flathub "org.freedesktop.Platform.VulkanLayer.MangoHud/$RUNTIME"
# Install RetroDeck
flatpak install -y flathub net.retrodeck.retrodeck
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

# Select "ProtonGE (Flatpak)" under Compatibility 
# For running Steam apps in Gamescope, use this in the launch properties of Steam:
# gamescope -f -H 2256 -S stretch -- %command% 
# For running Steam apps in Gamescope and MangoHud, use this in the launch properties of Steam:
# gamescope -f -H 2256 -S stretch -- mangohud %command% 
# To enable MangoHud for all Steam games:
# flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam


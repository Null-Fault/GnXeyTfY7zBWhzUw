# Flatpaks

# Install Steam

# Install RetroDeck 

gsettings set org.gnome.mutter experimental-features '["scale-monitor-framebuffer", "xwayland-native-scaling"]'
flatpak override --user --talk-name=org.freedesktop.Flatpak com.valvesoftware.Steam
flatpak override --user --talk-name=org.freedesktop.Flatpak net.retrodeck.retrodeck
flatpak override --user --system-talk-name=org.freedesktop.NetworkManager com.valvesoftware.Steam
# RetroDeck can add itself to Steam
# However the shortcut doesn't work
# Change it to:
# Target: /usr/bin/flatpak-spawn
# Launch Options: --host flatpak run net.retrodeck.retrodeck


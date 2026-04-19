# Flatpaks

# Install Steam

# Install RetroDeck 


flatpak override --user --talk-name=org.freedesktop.Flatpak com.valvesoftware.Steam
flatpak override --user --talk-name=org.freedesktop.Flatpak net.retrodeck.retrodeck
# RetroDeck can add itself to Steam
# However the shortcut doesn't work
# Change it to:
# Target: /usr/bin/flatpak-spawn
# Launch Options: --host flatpak run net.retrodeck.retrodeck


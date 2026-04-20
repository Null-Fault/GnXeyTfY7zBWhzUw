#!/bin/bash
set -euo pipefail

# Steam Flatpak
# This script installs Steam as a flatpak
# It also installs Gamescope.
# It also installs Proton.
# It also installs MangoHud.
# It also installs RetroDeck.

# Run gamescope
# Select "ProtonGE (Flatpak)" under Compatibility 
# For running Steam apps in Gamescope, use this in the launch properties of Steam:
# gamescope --fullscreen -H 2256 -S stretch -- %command%
# gamescope --fullscreen -W 2256 -H 1504 -- %command%
# gamescope --fullscreen -W 2256 -H 1504 --mangoapp --force-grab-cursor -- %command%
# Gamescope rendering the game session at half resolution and outputting at native
# gamescope --fullscreen -W 2256 -H 1504 -w 1128 -h 752 --mangoapp -- %command%
# Gamescope with FSR
# gamescope --fullscreen -W 2256 -H 1504 -w 1128 -h 752 -F fsr --mangoapp -- %command%
# For running Steam apps in Gamescope and MangoHud, use this in the launch properties of Steam:
# gamescope --fullscreen -H 2256 -S stretch --mangoapp -- %command%
# To enable MangoHud for all Steam games:
# flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam

# To configure launching flatpaks in Steam
# flatpak override --user --talk-name=org.freedesktop.Flatpak net.retrodeck.retrodeck
# RetroDeck can add itself to Steam
# However the shortcut doesn't work
# Change it to:
# Target: /usr/bin/flatpak-spawn
# Launch Options: --host flatpak run net.retrodeck.retrodeck

# Bluefin default Gnome scaling
# org.gnome.mutter experimental-features ['scale-monitor-framebuffer', 'xwayland-native-scaling']
# To set back
# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']"
# Remove Gnome scaling for better compatibility
# gsettings set org.gnome.mutter experimental-features "[]"

STEAM="com.valvesoftware.Steam"
PROTON="com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
GAMESCOPE="org.freedesktop.Platform.VulkanLayer.gamescope"
MANGOHUD="org.freedesktop.Platform.VulkanLayer.MangoHud"
RETRODECK="net.retrodeck.retrodeck"

echo "==> Adding Flathub remote (if not already present)..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "==> Installing Steam..."
flatpak install -y flathub "$STEAM"

# This is so Steam can start other flatpaks, e.g. emulators installed via Flatpak
flatpak override --user --talk-name=org.freedesktop.Flatpak "$STEAM"
# The speeds up startup but may expose network information
flatpak override --user --system-talk-name=org.freedesktop.NetworkManager "$STEAM"


echo "==> Detecting Steam SDK runtime..."
RUNTIME=$(flatpak info --show-metadata "$STEAM"  | grep '^sdk=' | sed 's|[^/]*/||')
# e.g. x86_64/25.08

echo "==> Installing Gamescope extension (Runtime: $RUNTIME)..."
flatpak install -y flathub "$PROTON"
flatpak install -y flathub "$GAMESCOPE/$RUNTIME"
flatpak install -y flathub "$MANGOHUD/$RUNTIME"
flatpak install -y flathub "$RETRODECK"


echo ""
echo "Done! Installed:"

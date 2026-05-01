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
# Use SDL backend (X11 compat) and grab cursor. Fixes wheel scroll issues in some games (e.g. Rimworld)
# gamescope --fullscreen -W 2256 -H 1504 --backend sdl --force-grab-cursor -- %command%
# Use FSR with SDL backend
# gamescope --fullscreen -W 2256 -H 1504 --backend sdl --force-grab-cursor --mangoapp -- %command%
# gamescope --fullscreen -W 2256 -H 1504 -r 60 -- %command%
# Displays Mangohub
# gamescope --fullscreen -W 2256 -H 1504 -r 60 --mangoapp --force-grab-cursor -- %command%
# Gamescope rendering the game session at half resolution and outputting at native
# gamescope --fullscreen -W 2256 -H 1504 -w 1620 -h 1080 -r 60 --mangoapp -- %command%
# Gamescope with FSR
# gamescope --fullscreen -W 2256 -H 1504 --filter fsr -w 1620 -h 1080 -r 60 --mangoapp -- %command%
# gamescope --fullscreen -W 2256 -H 1504 --filter fsr -w 1620 -h 1080 --backend sdl --force-grab-cursor --mangoapp -- %command%
# For running Steam apps in Gamescope and MangoHud, use this in the launch properties of Steam:
# gamescope --fullscreen -H 2256 -S stretch -r 60 --mangoapp -- %command%
# Stretch to width
# gamescope --fullscreen -H 2256 -S stretch -r 60 -- %command%
# To enable MangoHud for all Steam games:
# flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam

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

# # https://retrodeck.readthedocs.io/en/cooker/wiki_steam/steam-input/

# The following only applies to Linux Desktop:
# You must have enable all Steam Inputs in Steam
# # In Steam go to the Settings tab to go into the Steam Settings, press Controller, enable all Steam Inputs: Xbox PlayStation Switch Pro Generic.
# Device templates like Steam Deck

# Devices like the Steam Deck with a built-in controller you will be able to find the profile under Controller Settings -> Controller Layouts -> Templates.
# Connect the external controller to find the templates for them

# If you plan on using external controllers, you need to have the controller connected via either: Cable Bluetooth Wireless for the controller profile to show up automatically. You will find the profile under Controller Settings -> Controller Layouts -> Templates.


# This is so Steam can start other flatpaks, e.g. emulators (RetroDeck) installed via Flatpak
# https://retrodeck.readthedocs.io/en/cooker/wiki_steam/add-to-steam/#configuring-retrodeck-in-steam-flatpak
# Target: /usr/bin/flatpak-spawn
# Launch Options: --host flatpak run net.retrodeck.retrodeck
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

#!/bin/bash

set -euo pipefail

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_CONFIG="$SCRIPT_DIR/hyprland-overrides.conf"
SOURCE_LINE="source = $OVERRIDES_CONFIG"

echo "Installing hyprland overrides ..."

# Check if hyprland.conf exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland configuration file not found at $HYPRLAND_CONFIG."
    echo "Please ensure Hyprland is installed and configured correctly."
    exit 1
fi

# Check if ovverides config exists
if [ ! -f "$OVERRIDES_CONFIG" ]; then
    echo "Overrides configuration file not found at $OVERRIDES_CONFIG."
    echo "Please ensure the overrides file is present."
    exit 1
fi


#check if the overrides line already exists in hyprland.conf
if grep -Fxq "$SOURCE_LINE" "$HYPRLAND_CONFIG"; then
    echo "Source line already exists in $HYPRLAND_CONFIG. No changes made."
else
    echo "Installing Hyprland overrides..."
    echo "" >> "$HYPRLAND_CONFIG"
    echo "# Include custom overrides" >> "$HYPRLAND_CONFIG"
    echo "$SOURCE_LINE" >> "$HYPRLAND_CONFIG"
    echo "Source line added successfully."
fi

echo "Hyprland overrides installation script complete!"
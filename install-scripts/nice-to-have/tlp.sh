#!/bin/bash

# Prompt user for TLP installation
read -p "Would you like to install TLP for laptop power management? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "TLP installation skipped."
    exit 0
fi

# Install TLP 
echo "Installing TLP and optional dependencies..."
sudo pacman -S tlp --noconfirm

# Enable and start TLP service
echo "Enabling and starting TLP services..."
sudo systemctl enable --now tlp.service

# Mask conflicting services
echo "Masking systemd-rfkill service and socket..."
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

# GUI for TLP
echo "Installing TLP GUI (slimbookbettery)..."
yay -S --noconfirm slimbookbattery

echo "TLP installation and configuration completed successfully!"
#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Check for required tools
if ! command -v yay &> /dev/null; then
    echo "Error: yay not found. Please install yay first." >&2
    exit 1
fi

# Master installation script to run all other installation scripts in order
. ./essentials-install.sh

. ./gaming-install.sh

. ./nicetohave-install.sh

. ./ai-install.sh

# Remove unwanted software
. ./remove-shit.sh

# Update system
echo "Updating system packages ..."
sudo updatedb
yay -Syu --noconfirm --ignore uwsm
echo "We are done! So lets reboot now ..." # Reboot
sleep 2
reboot
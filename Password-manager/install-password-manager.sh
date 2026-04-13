#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

echo "Installing Password Manager ..."

sudo pacman -S --noconfirm --needed bitwarden


echo "Bitwarden installation and configuration completed!"
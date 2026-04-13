#!/bin/bash

echo "Removing 1Password ..."
yay -Rns --noconfirm $(yay -Qq 1password 1password-cli 1password-beta 2>/dev/null) 2>/dev/null || true
echo "1Password removed successfully."

echo "Removing basecamp ..."
omarchy-webapp-remove Basecamp

echo "Removing Zoom ..."
omarchy-webapp-remove Zoom
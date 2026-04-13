#!/bin/bash

# password manager
. ./Password-manager/install-password-manager.sh

# My hyperland setup
#. ./hypr/install-hyperland-overrides.sh

# set defaults script
#. ./hypr/set-default-variables.sh

# grahphics drivers install script
. ./install-scripts/gpu-setup.sh

# Wine compatibility layer for running Windows applications
. ./install-scripts/Wine.sh

# Windows applications management via Bottles
. ./install-scripts/Bottles.sh

#echo "Installing Native DXVK ..." # already included in bottles but this gives sysytem-wide DXVK support
#. ./install-scripts/Native-DXVK.sh
# required manual steps. Recommended though

# VPN client for accesing my services
bash ./install-scripts/tailscale.sh

# Visual Studio Code installation
. ./install-scripts/vscode.sh

# Webapps
. ./install-scripts/webapps/install-webapps.sh

# Browser
. ./install-scripts/browser.sh

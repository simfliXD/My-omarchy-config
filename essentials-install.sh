#!/bin/bash

# password manager
. ./install-scripts/bitwarden.sh

# My hyperland setup
#. ./hypr/install-hyperland-overrides.sh

# set defaults script
#. ./hypr/set-default-variables.sh

# grahphics drivers install script
. ./install-scripts/gpu-setup.sh

# Wine compatibility layer for running Windows applications
. ./install-scripts/Wine.sh

#echo "Installing Native DXVK ..." # already included in bottles but this gives sysytem-wide DXVK support
#. ./install-scripts/Native-DXVK.sh
# required manual steps. Recommended though

# VPN client for accesing my services
bash ./install-scripts/tailscale.sh

# Code Editors installation
. ./install-scripts/code-editors.sh

# Webapps
. ./install-scripts/webapps/install-webapps.sh

# Browser
. ./install-scripts/browser.sh

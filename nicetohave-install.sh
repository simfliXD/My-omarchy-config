#!/bin/sh

# There was som weird behaviour when trying to run the scripts.
NICETOHAVE_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing nice to haves ..."

# Lightweight spotify client
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/lightweight-spotify.sh"

# Omarchy themes
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/omarchy-themes.sh"

# Theme extension for Omarchy
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/themes-extension.sh"

# TLP for battery optimization on laptops
#. ./install-scripts/nice-to-have/tlp.sh # disabled for now due to conflicts with auto-cpufreq

# Gimp
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/gimp.sh"

# Davinci Resolve
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/davinchi-resolve.sh"
# ONLYOFFICE
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/onlyoffice.sh"
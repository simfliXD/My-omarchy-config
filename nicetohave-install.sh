#!/bin/sh

# There was som weird behaviour when trying to run the scripts.
NICETOHAVE_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing nice to haves ..."

# Lightweight spotify client
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/spotify-alternative/lightweight-spotify.sh"

# Omarchy themes
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/omarchy-themes.sh"

# Theme extension for Omarchy
. "$NICETOHAVE_SCRIPT_DIR/install-scripts/nice-to-have/themes-extension.sh"

# TLP for battery optimization on laptops
#. ./install-scripts/nice-to-have/tlp.sh # disabled for now due to conflicts with auto-cpufreq
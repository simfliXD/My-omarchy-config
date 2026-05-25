#!/bin/sh

echo "Setting things up for optimal gaming ..."

# Install Game Launchers/Library managers
. ./install-scripts/gaming/launchers.sh

# Install Gamescope
. ./install-scripts/gaming/gamescope.sh

# Install steam compatibility config
. ./install-scripts/gaming/steamcompatability/install-gamecompatability.sh

# Install gamemode
. ./install-scripts/gaming/gamemode/install-gamemode.sh

# Install auto-cpufreq
. ./install-scripts/gaming/power-management.sh

# Install mangohud and goverlay
. ./install-scripts/gaming/install-mangohud.sh

# Install LACT
. ./install-scripts/gaming/lact/LACT.sh

# Install Zen Kernel
. ./install-scripts/gaming/zen-kernel.sh


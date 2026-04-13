#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common.sh"

section "Installing Gamemode"

NEW_GAMEMODE_CONFIG="$SCRIPT_DIR/gamemode.ini"
CURRENT_GAMEMODE_CONFIG="/usr/share/gamemode/gamemode.ini"

log_info "Installing Gamemode packages..."
sudo pacman -S --noconfirm --needed gamemode lib32-gamemode

if [ ! -f "$NEW_GAMEMODE_CONFIG" ]; then
  log_error "gamemode.ini not found at $NEW_GAMEMODE_CONFIG"
  log_warn "Skipping gamemode configuration."
  exit 1
fi

sudo mkdir -p "$(dirname "$CURRENT_GAMEMODE_CONFIG")"
sudo rm -f "$CURRENT_GAMEMODE_CONFIG"
sudo cp "$NEW_GAMEMODE_CONFIG" "$CURRENT_GAMEMODE_CONFIG"
sudo chmod 644 "$CURRENT_GAMEMODE_CONFIG"

log_success "Gamemode config copied to $CURRENT_GAMEMODE_CONFIG"
log_info "Enabling gamemoded service for user session..."

if user_systemctl enable --now gamemoded; then
  log_success "Gamemode service enabled."
else
  log_warn "Could not enable gamemoded in the current user session. Start it manually after login with 'systemctl --user enable --now gamemoded'."
fi

log_info "Testing Gamemode installation..."
if gamemoded -t; then
  log_success "Gamemode is installed and working correctly!"
else
  log_warn "Gamemode test failed. Please check the installation."
fi

log_info "For Steam games, add 'gamemoderun %command%' to the launch options."
sleep 3


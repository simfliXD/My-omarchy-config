#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common.sh"

section "Installing Steam compatibility settings"

GAMECOMPAT_CONFIG="$SCRIPT_DIR/80-gamecompatability.conf"
GAMECOMPATABILITY_PATH="/etc/sysctl.d/80-gamecompatability.conf"

log_info "Applying recommended Steam compatibility tuning..."

if [ ! -f "$GAMECOMPAT_CONFIG" ]; then
  log_error "80-gamecompatability.conf not found at $GAMECOMPAT_CONFIG"
  log_warn "Skipping game compatibility configuration."
  exit 1
fi

sudo mkdir -p /etc/sysctl.d
sudo rm -f "$GAMECOMPATABILITY_PATH"
sudo cp "$GAMECOMPAT_CONFIG" "$GAMECOMPATABILITY_PATH"
sudo chmod 644 "$GAMECOMPATABILITY_PATH"

log_success "Game compatibility config copied to $GAMECOMPATABILITY_PATH"
log_info "Applying sysctl settings..."
sudo sysctl -p "$GAMECOMPATABILITY_PATH" >/dev/null
log_success "Sysctl settings applied successfully."

log_success "Game compatibility installation completed!"

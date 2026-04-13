#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Gamescope"

log_info "Installing Gamescope..."
sudo pacman -S --noconfirm --needed gamescope

if command -v gamescope >/dev/null 2>&1; then
  log_success "Gamescope installed successfully."
else
  log_error "Gamescope installation failed."
  exit 1
fi

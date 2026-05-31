#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing BetterBird"

info "Installing BetterBird..."

yay -S --needed --noconfirm betterbird-bin

if pacman -Qi betterbird-bin >/dev/null 2>&1; then
  log_success "BetterBird installed successfully!"
else
  log_error "BetterBird installation failed."
  exit 1
fi

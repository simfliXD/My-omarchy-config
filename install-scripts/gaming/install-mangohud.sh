#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Mangohud and Goverlay"

log_info "Installing Mangohud..."
sudo pacman -S --noconfirm --needed mangohud lib32-mangohud
if command -v mangohud >/dev/null 2>&1; then
  log_success "Mangohud installation completed!"
else
  log_error "Mangohud installation failed."
  exit 1
fi

log_info "Installing Goverlay..."
sudo pacman -S --noconfirm --needed goverlay
if command -v goverlay >/dev/null 2>&1; then
  log_success "Goverlay installation completed!"
else
  log_error "Goverlay installation failed."
  exit 1
fi

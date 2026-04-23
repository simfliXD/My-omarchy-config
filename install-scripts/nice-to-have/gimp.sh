#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Gimp"

log_info "Installing Gimp and PhotoGimp ( Photoshop like styling)..."

yay -S --needed --noconfirm gimp photogimp 

if pacman -Qi gimp >/dev/null 2>&1; then
  log_success "Gimp installed successfully!"
else
  log_error "Gimp installation failed."
  exit 1
fi

if pacman -Qi photogimp >/dev/null 2>&1; then
  log_success "PhotoGimp installed successfully!"
else
  log_error "PhotoGimp installation failed."
  exit 1
fi
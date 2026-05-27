#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Davinci Resolve"

log_info "Installing Davinci Resolve..."

#yay -S --needed --noconfirm davinci-resolve

if pacman -Qi davinci-resolve >/dev/null 2>&1; then
  log_success "Davinci Resolve installed successfully!"
else
  log_error "Davinci Resolve installation failed."
  # exit 1
fi


#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

section "Installing Browser"

log_info "Installing Zen Browser..."
yay -S --noconfirm --needed zen-browser-bin

if command -v zen-browser >/dev/null 2>&1; then
  log_info "Setting Zen Browser as default..."
  xdg-settings set default-web-browser zen.desktop
  log_success "Browser installation completed!"
else
  log_error "Browser installation failed."
  exit 1
fi

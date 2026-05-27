#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Omarchy themes extension"

log_info "Installing theme extension dependency..."
if yay -S --noconfirm --needed adw-gtk-theme; then
  log_success "adw-gtk-theme installed."
else
  log_error "Failed to install adw-gtk-theme."
  exit 1
fi

log_info "Installing Omarchy themes extension..."

if curl -fsSL https://raw.githubusercontent.com/OldJobobo/theme-hook-plugin-manager/thpm/install.sh | bash; then
  if command -v thpm >/dev/null 2>&1; then
    log_success "Omarchy themes extension installed successfully."
  else
    log_error "Failed to install Omarchy themes extension."
  fi
else
  log_error "Failed to install theme extension installer."
fi

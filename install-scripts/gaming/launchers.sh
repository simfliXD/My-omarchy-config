#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Game Launchers"

log_info "Installing Steam..."
yay -S --noconfirm --needed steam

if command -v steam >/dev/null 2>&1; then
  log_success "Steam installed successfully."
else
  log_error "Steam installation failed."
  exit 1
fi

log_info "Installing Faugus Launcher..."
yay -S --noconfirm --needed faugus-launcher

if command -v faugus-launcher >/dev/null 2>&1; then
  log_success "Faugus Launcher installed successfully."
else
  log_error "Faugus Launcher installation failed."
  exit 1
fi

log_info "Installing ATlauncher (Minecraft launcher)..."
yay -S --noconfirm --needed atlauncher-bin

if command -v atlauncher >/dev/null 2>&1; then
  log_success "ATlauncher installed successfully."
else
  log_error "ATlauncher installation failed."
  exit 1
fi

log_success "Game launchers installation completed!"

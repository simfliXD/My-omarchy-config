#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

section "Installing Tailscale"

require_command yay

log_info "Installing Tailscale package..."
sudo pacman -S --noconfirm --needed tailscale

log_info "Configuring Tailscale operator..."
sudo tailscale set --operator="$USER"

log_info "Enabling tailscaled service..."
sudo systemctl enable --now tailscaled

log_info "Starting Tailscale..."
tailscale up
log_success "Tailscale installation and setup completed!"

section "Installing TSUI"
log_info "Installing TSUI (Tailscale UI)..."
yay -S --noconfirm --needed tsui
log_success "TSUI installation completed!"

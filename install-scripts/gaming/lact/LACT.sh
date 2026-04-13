#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common.sh"

section "Installing LACT"

MY_LACT_CONFIG="$SCRIPT_DIR/config.yaml"
LACT_CONFIG_PATH="/etc/lact/config.yaml"

log_info "Installing LACT dependencies..."
sudo pacman -S --needed base-devel git clang make rust gtk4 hwdata vulkan-tools clinfo

log_info "Installing LACT package..."
sudo pacman -S --noconfirm --needed lact
log_success "LACT installed successfully."

if [ ! -f "$MY_LACT_CONFIG" ]; then
  log_error "config.yaml not found at $MY_LACT_CONFIG"
  log_warn "Skipping LACT configuration."
  exit 1
fi

sudo mkdir -p "$(dirname "$LACT_CONFIG_PATH")"
sudo rm -f "$LACT_CONFIG_PATH"
sudo cp "$MY_LACT_CONFIG" "$LACT_CONFIG_PATH"
sudo chmod 644 "$LACT_CONFIG_PATH"

log_success "LACT config copied to $LACT_CONFIG_PATH"
log_info "Enabling and starting LACT daemon..."
sudo systemctl enable --now lactd
log_success "LACT daemon enabled and started."

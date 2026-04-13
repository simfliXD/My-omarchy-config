#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

section "Installing Bottles"

log_info "Installing Bottles..."
yay -S --noconfirm --needed bottles

if command -v bottles >/dev/null 2>&1; then
  log_success "Bottles installation completed!"
else
  log_error "Bottles installation failed."
  exit 1
fi

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

section "Installing Wine compatibility layer ..."

log_info "Installing Wine..."
yay -S --noconfirm --needed wine wine-mono winetricks

if command -v wine >/dev/null 2>&1; then
  log_success "Wine installation completed!"
else
  log_error "Wine installation failed."
  exit 1
fi
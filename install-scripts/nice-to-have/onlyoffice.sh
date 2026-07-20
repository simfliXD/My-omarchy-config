#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

section "Installing ONLYOFFICE"

log_info "Installing ONLYOFFICE..."
yay -S --noconfirm --needed onlyoffice-bin

if command -v zen-ONLYOFFICE >/dev/null 2>&1; then
  log_success "ONLYOFFICE installation completed!"
else 
  log_error "ONLYOFFICE installation failed."
  exit 1
fi

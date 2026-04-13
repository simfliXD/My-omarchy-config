#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

section "Installing Visual Studio Code"

log_info "Installing VS Code..."
yay -S --noconfirm --needed visual-studio-code-bin

if command -v code >/dev/null 2>&1; then
  log_success "Visual Studio Code installation completed!"
else
  log_error "Visual Studio Code installation failed."
  exit 1
fi

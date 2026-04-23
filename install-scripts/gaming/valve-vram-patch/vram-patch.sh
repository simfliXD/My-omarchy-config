#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Valve VRAM Patch"

log_warn "⚠️  Kernel Requirement: Linux kernel version 7.0 or higher is required for this patch."
log_info "Installing dmemcg-booster..."

yay -S --needed --noconfirm gamemode  #plasma-foreground-booster-dmemcg
yay -S --needed --noconfirm dmemcg-booster

if pacman -Qi dmemcg-booster >/dev/null 2>&1; then
  log_success "Valve VRAM patch installed successfully!"
else
  log_error "Valve VRAM patch installation failed."
  exit 1
fi

# Problably easier to use the Cachyos kernel or wait for the patch to reach upstream linux.
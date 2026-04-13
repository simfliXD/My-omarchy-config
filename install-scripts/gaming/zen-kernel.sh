#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Zen Kernel"

log_info "Installing zen kernel for lower latency..."
sudo pacman -S --noconfirm --needed linux-zen linux-zen-headers

if pacman -Qi linux-zen >/dev/null 2>&1; then
  log_success "Zen kernel added. It's now available in limine boot menu upon next reboot!"
else
  log_error "Zen kernel installation failed."
  exit 1
fi

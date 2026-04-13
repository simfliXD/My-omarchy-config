#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

IS_LAPTOP=false
if [ -d /sys/class/power_supply ]; then
  if ls /sys/class/power_supply 2>/dev/null | grep -qi "bat"; then
    IS_LAPTOP=true
  fi
fi

section "Configuring Power Management"

if [ "$IS_LAPTOP" = true ]; then
  log_info "Laptop detected — Installing TLP (power optimization)..."
  sudo pacman -S --noconfirm --needed tlp tlp-rdw
  sudo systemctl enable --now tlp.service
  sudo systemctl mask power-profiles-daemon.service
  sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

  if command -v tlp >/dev/null 2>&1; then
    log_success "TLP installed and running."
  else
    log_error "TLP installation failed."
    exit 1
  fi
else
  log_info "Desktop detected — Installing auto-cpufreq for automatic CPU frequency scaling..."

  if command -v yay >/dev/null 2>&1; then
    yay -S --noconfirm --needed auto-cpufreq
  else
    sudo pacman -S --noconfirm --needed auto-cpufreq
  fi

  sudo systemctl stop auto-cpufreq || true
  sudo auto-cpufreq --install || true
  sudo systemctl enable --now auto-cpufreq.service || true

  if command -v auto-cpufreq >/dev/null 2>&1; then
    log_success "auto-cpufreq installed and running."
  else
    log_error "auto-cpufreq installation failed."
    exit 1
  fi
fi

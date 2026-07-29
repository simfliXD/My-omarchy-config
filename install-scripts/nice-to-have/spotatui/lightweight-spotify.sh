#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

section "Installing Spotatui"
log_info "Installing spotatui..."
yay -S --noconfirm --needed spotatui
log_success "spotatui installation completed!"

log_info "Copying spotatui.desktop file to /usr/share/applications..."
sudo cp "${SCRIPT_DIR}/spotatui.desktop" "/usr/share/applications/"
log_success "spotatui.desktop file copied successfully!"

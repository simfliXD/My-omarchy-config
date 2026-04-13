
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

section "Installing Omarchy themes extension"

log_info "Installing theme extension dependency..."
if sudo pacman -S --noconfirm --needed adw-gtk-theme; then
  log_success "adw-gtk-theme installed."
else
  log_error "Failed to install adw-gtk-theme."
  exit 1
fi

log_info "Installing Omarchy themes extension..."
if curl -fsSL https://imbypass.github.io/omarchy-theme-hook/install.sh | bash; then
  log_success "Omarchy themes extension installed successfully."
else
  log_error "Failed to install Omarchy themes extension."
  exit 1
fi
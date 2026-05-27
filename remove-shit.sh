#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install-scripts/common.sh"

section "Removing useless stuff ..."

info "Removing 1Password ..."
yay -Rns --noconfirm $(yay -Qq 1password 1password-cli 1password-beta 2>/dev/null) 2>/dev/null || true
success "1Password removed successfully."

info "Removing basecamp ..."
omarchy webapp remove Basecamp

info "Removing Zoom ..."
omarchy webapp remove Zoom

info "Removing cliamp ..."
yay -Rns --noconfirm $(yay -Qq cliamp 2>/dev/null) 2>/dev/null || true

success "Removed everything successfully."

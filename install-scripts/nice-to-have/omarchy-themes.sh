#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common.sh"

OMARCHY_BIN_DIR="${OMARCHY_BIN_DIR:-$HOME/.local/share/omarchy/bin}"
if [ -x "$OMARCHY_BIN_DIR/omarchy-theme-list" ]; then
  PATH="$OMARCHY_BIN_DIR:$PATH"
fi

require_command omarchy-theme-list
require_command omarchy-theme-install
require_command omarchy-theme-update
require_command omarchy-theme-set

THEME_REPOS=(
  https://github.com/YutaKoyanagi10/omarchy-koyanagi-theme
  https://github.com/JJDizz1L/aetheria.git
  https://github.com/davidguttman/archwave
  https://github.com/bjarneo/omarchy-aura-theme
  https://github.com/HANCORE-linux/omarchy-blackgold-theme.git
  https://github.com/catlee/omarchy-dracula-theme
  https://github.com/bjarneo/omarchy-futurism-theme
  https://github.com/sc0ttman/omarchy-one-dark-pro-theme
)

normalize_name() {
  echo "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

repo_to_theme_name() {
  basename "$1" |
    sed -E 's/\.git$//' |
    sed -E 's/^omarchy-//' |
    sed -E 's/-theme$//' |
    tr '-' ' ' |
    awk '{ for (i = 1; i <= NF; i++) $i = toupper(substr($i,1,1)) substr($i,2) }1'
}

section "Installing Omarchy themes"
log_info "Fetching installed theme list..."
INSTALLED_THEMES="$(omarchy-theme-list)"

NORMALIZED_INSTALLED_THEMES="$(printf '%s\n' "$INSTALLED_THEMES" | while IFS= read -r LINE; do normalize_name "$LINE"; done)"

log_info "Installing missing themes (parallel)..."
for REPO in "${THEME_REPOS[@]}"; do
  NAME="$(repo_to_theme_name "$REPO")"
  NORMALIZED_NAME="$(normalize_name "$NAME")"

  if printf '%s\n' "$NORMALIZED_INSTALLED_THEMES" | grep -Fxq "$NORMALIZED_NAME"; then
    log_success "Already installed: $NAME"
  else
    log_info "Installing: $NAME"
    omarchy-theme-install "$REPO" &
  fi
done

wait

log_info "Updating all themes..."
omarchy-theme-update

log_info "Setting theme back to Tokyo Night"
omarchy-theme-set Tokyo-Night

log_success "Theme update completed."
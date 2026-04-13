#!/usr/bin/env bash
set -euo pipefail

LIGHTWEIGHT_SPOTIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIGHTWEIGHT_SPOTIFY_DIR}/../../common.sh"

SPOTIFYD_CONFIG_PATH="$HOME/.config/spotifyd/spotifyd.conf"

section "Installing Spotify clients"

log_info "Installing spotifyd..."
sudo pacman -S --noconfirm --needed spotifyd

if [ -d "$HOME/dotfiles" ]; then
  cd "$HOME/dotfiles" && stow -R spotifyd
  log_success "spotifyd config applied successfully using stow."
else
  log_warn "No $HOME/dotfiles directory found; skipping spotifyd config deployment."
fi

log_info "Enabling spotifyd service for the current user..."
if user_systemctl enable spotifyd.service --now; then
  log_success "spotifyd service enabled."
else
  log_warn "Could not enable spotifyd in the current user session. Start it manually after login."
fi

if [ -f "$HOME/.config/spotifyd/spotifyd.token" ] || \
   [ -f "$HOME/.config/refresh_token" ] || \
   [ -d "$HOME/.cache/spotifyd" ] || \
   grep -qE 'refresh_token|access_token|oauth|client_id' "$SPOTIFYD_CONFIG_PATH" >/dev/null 2>&1; then
  log_info "spotifyd appears already authenticated — skipping interactive authenticate."
else
  log_info "No spotifyd authentication found; running spotifyd authenticate."
  spotifyd authenticate
fi

log_success "spotifyd installation and configuration completed!"

section "Installing Spotify-Qt"
log_info "Installing spotify-qt..."
if yay -S --noconfirm --needed spotify-qt; then
  log_success "spotify-qt installed successfully."
  log_warn "spotify-qt must be launched manually in a desktop session to complete first-time setup."
else
  log_error "Failed to install spotify-qt."
  exit 1
fi

section "Installing Spotatui"
log_info "Installing spotatui..."
yay -S --noconfirm --needed spotatui
log_success "spotatui installation completed!"

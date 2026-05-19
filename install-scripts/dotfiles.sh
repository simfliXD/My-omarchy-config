#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

mkdir -p "$HOME"/dotfiles
git clone https://github.com/simfliXD/my-omarchy-dotfiles.git "$HOME"/dotfiles

info "dotfiles cloned to $HOME/dotfiles."

sudo pacman -S --noconfirm --needed stow

cd "$HOME"/dotfiles

# Stow the dotfiles for the desired applications
stow *
info "dotfiles stowed to $HOME/dotfiles."
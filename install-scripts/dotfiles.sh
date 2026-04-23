#!/bin/bash

mkdir -p "$HOME"/dotfiles
git clone https://github.com/simfliXD/my-omarchy-dotfiles.git "$HOME"/dotfiles

echo "dotfiles cloned to $HOME/dotfiles."

sudo pacman -S --noconfirm --needed stow

cd "$HOME"/dotfiles

# Stow the dotfiles for the desired applications
stow *
echo "dotfiles stowed to $HOME/dotfiles."
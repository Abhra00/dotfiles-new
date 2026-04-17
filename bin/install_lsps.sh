#!/bin/bash

echo "Installing language servers..."

# C/C++
sudo pacman -S --noconfirm clang

# Go
sudo pacman -S --noconfirm gopls

# Rust
rustup component add rust-analyzer

# Python, JS/TS, CSS/JSON/HTML, YAML
npm install -g \
  basedpyright \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server

echo "All done!"

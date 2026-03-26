#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/SylEleuth/gruvbox-plus-icon-pack.git"
THEME_NAME="Gruvbox-Plus-Dark"
INSTALL_DIR="/usr/share/icons"
TMP_DIR="$(mktemp -d)"

# Ensure cleanup on exit
trap 'rm -rf "$TMP_DIR"' EXIT

# deps
command -v git >/dev/null || { echo "git not found"; exit 1; }
command -v gum >/dev/null || { echo "gum not found"; exit 1; }

# Pre-authenticate sudo to prevent gum spin from hiding the prompt
sudo -v

gum style --foreground 212 "Installing $THEME_NAME..."

# clone 
gum spin --spinner dot --title "Cloning repository..." -- git clone --depth=1 "$REPO_URL" "$TMP_DIR/repo"

# check
if [ ! -d "$TMP_DIR/repo/$THEME_NAME" ]; then
    gum style --foreground 196 "Theme folder not found in repository."
    exit 1
fi

# overwrite check
if [ -d "$INSTALL_DIR/$THEME_NAME" ]; then
    gum confirm "Theme already exists. Replace it?" && sudo rm -rf "$INSTALL_DIR/$THEME_NAME" || exit 0
fi

# install
gum spin --spinner line --title "Copying to $INSTALL_DIR..." -- sudo mv "$TMP_DIR/repo/$THEME_NAME" "$INSTALL_DIR/"

# update cache (ignore fail)
if command -v gtk-update-icon-cache >/dev/null; then
    # Changed "dots" to "points" to satisfy gum's strict enum
    gum spin --spinner points --title "Updating icon cache..." -- sudo gtk-update-icon-cache -f "$INSTALL_DIR/$THEME_NAME" || true
fi

gum style --foreground 82 "Successfully installed $THEME_NAME!"

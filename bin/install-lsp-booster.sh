#!/usr/bin/env bash
set -euo pipefail

BIN=/usr/local/bin/emacs-lsp-booster
API=https://api.github.com/repos/blahgeek/emacs-lsp-booster/releases/latest

echo "Fetching latest release info..."
URL=$(curl -fsSL "$API" \
  | grep -o '"browser_download_url": *"[^"]*x86_64-unknown-linux-musl[^"]*\.zip"' \
  | grep -o 'https://[^"]*')

if [ -z "$URL" ]; then
  echo "ERROR: Could not find download URL"
  exit 1
fi

echo "Downloading $URL..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" -o "$TMP/booster.zip"
unzip -q "$TMP/booster.zip" -d "$TMP"
sudo cp "$TMP/emacs-lsp-booster" "$BIN"

echo "Installed at $BIN"

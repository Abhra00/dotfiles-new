#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
REPO="adobe-fonts/source-code-pro"
FONT_NAME="Source Code Pro"
FONT_DIR="/usr/share/fonts/SourceCodePro"
VERSION_FILE="$FONT_DIR/.version"
TEMP_DIR=""
FONT_ZIP=""
USE_GUM=false

# ------------------------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------------------------
cleanup() {
  local exit_code=$?
  [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
  [[ -n "$FONT_ZIP" && -f "$FONT_ZIP" ]] && rm -f "$FONT_ZIP"
  exit "$exit_code"
}
trap cleanup EXIT INT TERM

# ------------------------------------------------------------------------------
# Dependency checks
# ------------------------------------------------------------------------------
check_dependencies() {
  local missing=()

  for cmd in curl jq unzip fc-cache; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done

  if (( ${#missing[@]} )); then
    echo "Missing required dependencies: ${missing[*]}"
    exit 1
  fi

  if command -v gum &>/dev/null; then
    USE_GUM=true
  fi
}

# ------------------------------------------------------------------------------
# UI helpers
# ------------------------------------------------------------------------------
info() {
  if $USE_GUM; then
    gum style --foreground 13 "$1"
  else
    echo -e "\033[1;35m$1\033[0m"
  fi
}

success() {
  if $USE_GUM; then
    gum style --foreground 10 "$1"
  else
    echo -e "\033[1;32m$1\033[0m"
  fi
}

error() {
  if $USE_GUM; then
    gum style --foreground 9 "$1"
  else
    echo -e "\033[1;31m$1\033[0m"
  fi
}

spin() {
  local title="$1"; shift
  if $USE_GUM; then
    gum spin --spinner globe --title "$title" -- "$@"
  else
    echo "$title"
    "$@"
  fi
}

# ------------------------------------------------------------------------------
# Fetch latest release
# ------------------------------------------------------------------------------
get_latest_release() {
  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest"
}

# ------------------------------------------------------------------------------
# Version check
# ------------------------------------------------------------------------------
check_version() {
  local new_version="$1"

  if [[ -f "$VERSION_FILE" ]]; then
    local installed
    installed=$(<"$VERSION_FILE")

    if [[ "$installed" == "$new_version" ]]; then
      success "✓ $FONT_NAME already up to date ($new_version)"
      exit 0
    else
      info "Updating $FONT_NAME: $installed → $new_version"
    fi
  fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  check_dependencies

  info "Fetching latest $FONT_NAME release…"
  RELEASE_JSON=$(get_latest_release)

  VERSION=$(jq -r '.tag_name' <<<"$RELEASE_JSON")
  [[ -z "$VERSION" || "$VERSION" == "null" ]] && error "Failed to determine version" && exit 1

  check_version "$VERSION"

  ASSET_URL=$(jq -r '
    .assets[]?
    | select(.name | test("^TTF-source-code-pro-.*\\.zip$"))
    | .browser_download_url
  ' <<<"$RELEASE_JSON")

  [[ -z "$ASSET_URL" || "$ASSET_URL" == "null" ]] && error "TTF zip not found in release" && exit 1

  info "Version: $VERSION"
  info "Downloading: $(basename "$ASSET_URL")"

  spin "Downloading font archive…" curl -fsSL -O "$ASSET_URL"
  FONT_ZIP=$(basename "$ASSET_URL")

  info "Requesting sudo access…"
  sudo -v

  # Keep sudo alive
  while true; do sudo -n true; sleep 45; kill -0 "$$" || exit; done 2>/dev/null &
  SUDO_KEEPER=$!

  TEMP_DIR=$(mktemp -d)
  info "Extracting fonts…"
  unzip -q "$FONT_ZIP" -d "$TEMP_DIR"

  info "Installing fonts to $FONT_DIR…"
  sudo rm -rf "$FONT_DIR"
  sudo mkdir -p "$FONT_DIR"
  sudo find "$TEMP_DIR" -type f -name "*.ttf" -exec cp {} "$FONT_DIR" \;

  echo "$VERSION" | sudo tee "$VERSION_FILE" >/dev/null

  info "Updating font cache…"
  sudo fc-cache -f "$FONT_DIR" >/dev/null

  kill "$SUDO_KEEPER" 2>/dev/null || true

  success "✓ $FONT_NAME installed successfully"
  success "✓ Version: $VERSION"
}

main

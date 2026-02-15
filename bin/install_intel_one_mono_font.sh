#!/usr/bin/env bash
set -euo pipefail

# Configuration
REPO="intel/intel-one-mono"
FONT_DIR="/usr/share/fonts/INTEL-ONE-MONO"
VERSION_FILE="$FONT_DIR/.version"
TEMP_DIR=""

# Cleanup function
cleanup() {
  local exit_code=$?
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
  if [ -n "${OTF_ZIP:-}" ]; then
    rm -f "$OTF_ZIP" 2>/dev/null || true
  fi
  if [ -n "${TTF_ZIP:-}" ]; then
    rm -f "$TTF_ZIP" 2>/dev/null || true
  fi
  exit $exit_code
}
trap cleanup EXIT INT TERM

# Check for required dependencies
check_dependencies() {
  local missing_deps=()
  for cmd in curl unzip jq; do
    if ! command -v "$cmd" &>/dev/null; then
      missing_deps+=("$cmd")
    fi
  done
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "Error: Missing required dependencies: ${missing_deps[*]}"
    echo "Please install them and try again."
    exit 1
  fi
  # Check for gum (optional, but used if available)
  if ! command -v gum &>/dev/null; then
    echo "Note: 'gum' not found. Install it for better UI (https://github.com/charmbracelet/gum)"
    USE_GUM=false
  else
    USE_GUM=true
  fi
}

# Styling functions that work with or without gum
style_info() {
  if [ "$USE_GUM" = true ]; then
    gum style --foreground='13' "$1"
  else
    echo -e "\033[1;35m$1\033[0m"
  fi
}

style_success() {
  if [ "$USE_GUM" = true ]; then
    gum style --foreground='10' "$1"
  else
    echo -e "\033[1;32m$1\033[0m"
  fi
}

style_error() {
  if [ "$USE_GUM" = true ]; then
    gum style --foreground='9' "$1"
  else
    echo -e "\033[1;31m$1\033[0m"
  fi
}

spinner_run() {
  local title="$1"
  shift
  if [ "$USE_GUM" = true ]; then
    gum spin --spinner globe --title "$title" -- "$@"
  else
    echo "$title"
    "$@"
  fi
}

# Get latest release info
get_latest_release() {
  local release_json
  release_json=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
  if [ -z "$release_json" ] || [ "$release_json" = "null" ]; then
    style_error "Error: Could not fetch release information from GitHub"
    exit 1
  fi
  echo "$release_json"
}

# Check if already up to date
check_version() {
  local current_version="$1"
  if [ -f "$VERSION_FILE" ]; then
    local installed_version
    installed_version=$(cat "$VERSION_FILE")
    if [ "$installed_version" == "$current_version" ]; then
      style_success "✓ Already on latest version ($current_version)"
      exit 0
    else
      style_info "Updating from $installed_version to $current_version"
    fi
  fi
}

# Main installation process
main() {
  # Check dependencies first
  check_dependencies

  style_info "Fetching latest release information..."

  # Get release information
  RELEASE_JSON=$(get_latest_release)
  CURRENT_VERSION=$(echo "$RELEASE_JSON" | jq -r '.tag_name')

  if [ -z "$CURRENT_VERSION" ] || [ "$CURRENT_VERSION" = "null" ]; then
    style_error "Error: Could not determine latest version"
    exit 1
  fi

  # Check if already installed
  check_version "$CURRENT_VERSION"

  # Get asset URLs for both OTF and TTF using jq for robust parsing
  OTF_URL=$(jq -r '
  .assets[]?
  | select(.name == "otf.zip")
  | .browser_download_url' <<<"$RELEASE_JSON")

  TTF_URL=$(jq -r '
  .assets[]?
  | select(.name == "ttf.zip")
  | .browser_download_url' <<<"$RELEASE_JSON")

  if [ -z "$OTF_URL" ] && [ -z "$TTF_URL" ]; then
    style_error "Error: Could not find font archives in latest release"
    exit 1
  fi

  # Display download information
  style_info "Version: $CURRENT_VERSION"
  if [ -n "$OTF_URL" ]; then
    style_info "Downloading OTF from: $OTF_URL"
  fi
  if [ -n "$TTF_URL" ]; then
    style_info "Downloading TTF from: $TTF_URL"
  fi

  # Download files
  if [ -n "$OTF_URL" ]; then
    spinner_run "Downloading OTF font files..." curl -fsSL -O "$OTF_URL"
    style_success "OTF download complete!"
  fi

  if [ -n "$TTF_URL" ]; then
    spinner_run "Downloading TTF font files..." curl -fsSL -O "$TTF_URL"
    style_success "TTF download complete!"
  fi

  # Get file names
  OTF_ZIP="$(basename "$OTF_URL")"
  TTF_ZIP="$(basename "$TTF_URL")"

  # Request sudo access once
  style_info "Requesting administrative privileges..."
  sudo -v

  # Keep sudo alive in background
  while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPER_PID=$!

  # Setup font directory
  style_info "Setting up font directory..."
  if [ -d "$FONT_DIR" ]; then
    style_info "$FONT_DIR already exists. Removing old installation..."
    sudo rm -rf "$FONT_DIR"
  fi
  sudo mkdir -p "$FONT_DIR"

  # Extract fonts to temporary directory
  TEMP_DIR=$(mktemp -d)
  style_info "Extracting fonts..."

  if [ -n "$OTF_ZIP" ] && [ -f "$OTF_ZIP" ]; then
    unzip -q "$OTF_ZIP" -d "$TEMP_DIR"
  fi

  if [ -n "$TTF_ZIP" ] && [ -f "$TTF_ZIP" ]; then
    unzip -q "$TTF_ZIP" -d "$TEMP_DIR"
  fi

  # Install fonts
  style_info "Installing fonts..."
  sudo find "$TEMP_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONT_DIR" \;

  # Save version information
  echo "$CURRENT_VERSION" | sudo tee "$VERSION_FILE" >/dev/null

  # Update font cache
  style_info "Updating font cache..."
  if fc-cache -fv "$FONT_DIR" >/dev/null 2>&1; then
    style_success "✓ Font cache updated"
  else
    style_error "Warning: Font cache update may have failed"
  fi

  # Kill sudo keeper process
  kill $SUDO_KEEPER_PID 2>/dev/null || true

  # Success message
  style_success "✓ Fonts installed successfully to $FONT_DIR"
  style_success "✓ Installed version: $CURRENT_VERSION"

}

# Run main function
main

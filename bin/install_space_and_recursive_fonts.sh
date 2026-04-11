#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════
#  Font Installer — Space Mono & Recursive
#  Requires: gum, git, curl, unzip, sudo, fc-cache
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# ── Destinations ─────────────────────────────────────────
SPACEMONO_REPO="https://github.com/googlefonts/spacemono.git"
SPACEMONO_DEST="/usr/share/fonts/SpaceMono"

RECURSIVE_API="https://api.github.com/repos/arrowtype/recursive/releases/latest"
RECURSIVE_DEST="/usr/share/fonts/Recursive"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# ── Helpers ──────────────────────────────────────────────
info()    { gum style --foreground 82  "✓ $*"; }
warn()    { gum style --foreground 214 "⚠  $*"; }
abort()   { gum style --foreground 196 "✗ $*"; exit 1; }

install_font_dir() {
  local dest="$1"
  if [ -d "$dest" ]; then
    warn "${dest} already exists — removing it …"
    sudo rm -rf "$dest"
    info "Old directory removed"
  fi
  sudo mkdir -p "$dest"
}

refresh_cache() {
  local dest="$1"
  gum spin --spinner pulse --title "Refreshing font cache for ${dest} …" \
    -- sudo fc-cache -fv "$dest" &>/dev/null
  info "Font cache updated"
}

# ── Dependency check ─────────────────────────────────────
for cmd in gum git curl unzip sudo fc-cache; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed. Please install it and try again." >&2
    exit 1
  fi
done

# ── Banner ───────────────────────────────────────────────
gum style \
  --border double \
  --border-foreground 212 \
  --padding "1 4" \
  --margin "1 2" \
  --bold \
  "  Font Installer" \
  "  Space Mono  ·  Recursive  "

# ── Font selection ───────────────────────────────────────
CHOICES=$(gum choose --no-limit \
  --header "Select fonts to install (space to toggle, enter to confirm):" \
  "Space Mono  → ${SPACEMONO_DEST}" \
  "Recursive   → ${RECURSIVE_DEST}")

[[ -z "$CHOICES" ]] && abort "Nothing selected. Exiting."

INSTALL_SPACEMONO=false
INSTALL_RECURSIVE=false
echo "$CHOICES" | grep -q "Space Mono"  && INSTALL_SPACEMONO=true
echo "$CHOICES" | grep -q "Recursive"   && INSTALL_RECURSIVE=true

# ════════════════════════════════════════════════════════
#  SPACE MONO
# ════════════════════════════════════════════════════════
if $INSTALL_SPACEMONO; then
  gum style --bold --margin "1 0" "── Space Mono ──────────────────────────"

  gum confirm "Install Space Mono to ${SPACEMONO_DEST}?" || {
    warn "Skipping Space Mono."
    INSTALL_SPACEMONO=false
  }
fi

if $INSTALL_SPACEMONO; then
  gum spin --spinner dot --title "Cloning googlefonts/spacemono …" \
    -- git clone --depth=1 --quiet "$SPACEMONO_REPO" "$TMP_DIR/spacemono"
  info "Repository cloned"

  install_font_dir "$SPACEMONO_DEST"

  # Collect font files
  SM_FILES=()
  while IFS= read -r -d '' f; do
    SM_FILES+=("$f")
  done < <(find "$TMP_DIR/spacemono/fonts" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0)

  [[ "${#SM_FILES[@]}" -eq 0 ]] && abort "No font files found in the spacemono repo."

  gum spin --spinner meter \
    --title "Installing ${#SM_FILES[@]} Space Mono font file(s) …" \
    -- sudo cp -r "$TMP_DIR/spacemono/fonts/." "$SPACEMONO_DEST/"
  info "Fonts copied to ${SPACEMONO_DEST}"

  refresh_cache "$SPACEMONO_DEST"
fi

# ════════════════════════════════════════════════════════
#  RECURSIVE
# ════════════════════════════════════════════════════════
if $INSTALL_RECURSIVE; then
  gum style --bold --margin "1 0" "── Recursive ───────────────────────────"

  # ── Fetch latest release metadata via GitHub API ──────
  gum spin --spinner dot --title "Fetching latest Recursive release info …" \
    -- bash -c "curl -fsSL '${RECURSIVE_API}' > '${TMP_DIR}/recursive_release.json'"

  # Parse tag name and find the matching zip asset (ArrowType-Recursive-*.zip)
  LATEST_TAG=$(grep -m1 '"tag_name"' "$TMP_DIR/recursive_release.json" \
    | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/')

  # Version number without the leading 'v' (e.g. v1.085 → 1.085)
  VERSION="${LATEST_TAG#v}"

  # Find the browser_download_url for ArrowType-Recursive-*.zip
  ZIP_URL=$(grep '"browser_download_url"' "$TMP_DIR/recursive_release.json" \
    | grep -i 'ArrowType-Recursive-.*\.zip' \
    | head -1 \
    | sed 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/')

  if [[ -z "$ZIP_URL" ]]; then
    # Fallback: construct the canonical URL from the tag
    ZIP_URL="https://github.com/arrowtype/recursive/releases/download/${LATEST_TAG}/ArrowType-Recursive-${VERSION}.zip"
    warn "Could not auto-detect zip URL from API; using constructed URL."
  fi

  ZIP_NAME="$(basename "$ZIP_URL")"
  info "Latest release: ${LATEST_TAG}  →  ${ZIP_NAME}"

  gum confirm "Install Recursive ${LATEST_TAG} to ${RECURSIVE_DEST}?" || {
    warn "Skipping Recursive."
    INSTALL_RECURSIVE=false
  }
fi

if $INSTALL_RECURSIVE; then
  # ── Download zip ──────────────────────────────────────
  gum spin --spinner meter \
    --title "Downloading ${ZIP_NAME} …" \
    -- curl -fsSL --output "$TMP_DIR/${ZIP_NAME}" "$ZIP_URL"
  info "Downloaded ${ZIP_NAME}"

  # ── Extract ───────────────────────────────────────────
  gum spin --spinner dot \
    --title "Extracting ${ZIP_NAME} …" \
    -- unzip -q "$TMP_DIR/${ZIP_NAME}" -d "$TMP_DIR/recursive_extracted"
  info "Archive extracted"

  # ── Install ───────────────────────────────────────────
  install_font_dir "$RECURSIVE_DEST"

  # Find all .ttf / .otf / .woff2 files recursively in the extracted archive
  REC_FILES=()
  while IFS= read -r -d '' f; do
    REC_FILES+=("$f")
  done < <(find "$TMP_DIR/recursive_extracted" -type f \
    \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.woff2" \) -print0)

  [[ "${#REC_FILES[@]}" -eq 0 ]] && abort "No font files found inside ${ZIP_NAME}."

  gum spin --spinner meter \
    --title "Installing ${#REC_FILES[@]} Recursive font file(s) …" \
    -- bash -c "find '$TMP_DIR/recursive_extracted' -type f \
      \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.woff2' \) \
      -exec sudo cp -v {} '$RECURSIVE_DEST/' \;" &>/dev/null
  info "Fonts copied to ${RECURSIVE_DEST}"

  refresh_cache "$RECURSIVE_DEST"
fi

# ════════════════════════════════════════════════════════
#  SUMMARY
# ════════════════════════════════════════════════════════
SUMMARY_LINES=()
if $INSTALL_SPACEMONO; then
  SM_COUNT=$(fc-list | grep -ic 'SpaceMono\|Space Mono' || true)
  SUMMARY_LINES+=("✓ Space Mono  — ${SM_COUNT} face(s) registered")
fi
if $INSTALL_RECURSIVE; then
  REC_COUNT=$(fc-list | grep -ic 'Recursive' || true)
  SUMMARY_LINES+=("✓ Recursive ${LATEST_TAG}  — ${REC_COUNT} face(s) registered")
fi

if [[ "${#SUMMARY_LINES[@]}" -gt 0 ]]; then
  gum style \
    --border rounded \
    --border-foreground 82 \
    --padding "1 3" \
    --margin "1 2" \
    --bold \
    "Installation complete!" \
    "" \
    "${SUMMARY_LINES[@]}"
else
  warn "No fonts were installed."
fi

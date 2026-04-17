#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════
#  Font Installer — Space Mono, Maple Mono & Aporetic
#  Requires: gum, git, curl, unzip, sha256sum, jq, sudo, fc-cache
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# ── Destinations ─────────────────────────────────────────
SPACEMONO_REPO="https://github.com/googlefonts/spacemono.git"
SPACEMONO_DEST="/usr/share/fonts/SpaceMono"

MAPLEMONO_REPO="subframe7536/maple-font"
MAPLEMONO_DEST="/usr/share/fonts/MapleMono"
MAPLEMONO_VERSION_FILE="$MAPLEMONO_DEST/.version"

APORETIC_REPO="https://github.com/protesilaos/aporetic.git"
APORETIC_DEST="/usr/share/fonts/Aporetic-Super-Family"

TMP_DIR="$(mktemp -d)"
SUDO_KEEPER_PID=""

trap 'cleanup' EXIT INT TERM

# ── Cleanup ───────────────────────────────────────────────
cleanup() {
  rm -rf "$TMP_DIR"
  [[ -n "$SUDO_KEEPER_PID" ]] && kill "$SUDO_KEEPER_PID" 2>/dev/null || true
}

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

keep_sudo_alive() {
  sudo -v
  while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPER_PID=$!
}

# ── Dependency check ─────────────────────────────────────
for cmd in gum git curl unzip sha256sum jq sudo fc-cache; do
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
  "  Space Mono  ·  Maple Mono  ·  Aporetic  "

# ── Font selection ───────────────────────────────────────
CHOICES=$(gum choose --no-limit \
  --header "Select fonts to install (space to toggle, enter to confirm):" \
  "Space Mono  → ${SPACEMONO_DEST}" \
  "Maple Mono  → ${MAPLEMONO_DEST}" \
  "Aporetic    → ${APORETIC_DEST}")

[[ -z "$CHOICES" ]] && abort "Nothing selected. Exiting."

INSTALL_SPACEMONO=false
INSTALL_MAPLEMONO=false
INSTALL_APORETIC=false
echo "$CHOICES" | grep -q "Space Mono"  && INSTALL_SPACEMONO=true
echo "$CHOICES" | grep -q "Maple Mono"  && INSTALL_MAPLEMONO=true
echo "$CHOICES" | grep -q "Aporetic"    && INSTALL_APORETIC=true

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
#  MAPLE MONO
# ════════════════════════════════════════════════════════
if $INSTALL_MAPLEMONO; then
  gum style --bold --margin "1 0" "── Maple Mono ──────────────────────────"

  gum spin --spinner dot --title "Fetching latest Maple Mono release info …" \
    -- bash -c "curl -fsSL 'https://api.github.com/repos/${MAPLEMONO_REPO}/releases/latest' \
        > '${TMP_DIR}/maplemono_release.json'"

  LATEST_TAG=$(jq -r '.tag_name' "$TMP_DIR/maplemono_release.json")

  if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
    abort "Could not determine latest Maple Mono version."
  fi

  if [[ -f "$MAPLEMONO_VERSION_FILE" ]]; then
    INSTALLED_VERSION=$(cat "$MAPLEMONO_VERSION_FILE")
    if [[ "$INSTALLED_VERSION" == "$LATEST_TAG" ]]; then
      info "Maple Mono ${LATEST_TAG} is already installed — skipping."
      INSTALL_MAPLEMONO=false
    else
      warn "Updating Maple Mono from ${INSTALLED_VERSION} to ${LATEST_TAG} …"
    fi
  fi
fi

if $INSTALL_MAPLEMONO; then
  ASSET_URL=$(jq -r '
    .assets[]
    | select(.name | test("MapleMono-CN-unhinted.*\\.zip$") and (test("NF") | not))
    | .browser_download_url' "$TMP_DIR/maplemono_release.json" | head -n1)

  CHECKSUM_URL=$(jq -r '
    .assets[]
    | select(.name | test("MapleMono-CN-unhinted.*\\.sha256$") and (test("NF") | not))
    | .browser_download_url' "$TMP_DIR/maplemono_release.json" | head -n1)

  [[ -z "$ASSET_URL"    ]] && abort "Could not find Maple Mono zip asset in release."
  [[ -z "$CHECKSUM_URL" ]] && abort "Could not find Maple Mono checksum asset in release."

  ZIP_NAME="$(basename "$ASSET_URL")"
  info "Latest release: ${LATEST_TAG}  →  ${ZIP_NAME}"

  gum confirm "Install Maple Mono ${LATEST_TAG} to ${MAPLEMONO_DEST}?" || {
    warn "Skipping Maple Mono."
    INSTALL_MAPLEMONO=false
  }
fi

if $INSTALL_MAPLEMONO; then
  ZIP_NAME="$(basename "$ASSET_URL")"
  CHECKSUM_NAME="$(basename "$CHECKSUM_URL")"

  gum spin --spinner meter \
    --title "Downloading ${ZIP_NAME} …" \
    -- curl -fsSL --output "$TMP_DIR/${ZIP_NAME}" "$ASSET_URL"
  info "Downloaded ${ZIP_NAME}"

  gum spin --spinner dot \
    --title "Downloading checksum …" \
    -- curl -fsSL --output "$TMP_DIR/${CHECKSUM_NAME}" "$CHECKSUM_URL"
  info "Downloaded checksum"

  HASH=$(tr -d '\n' < "$TMP_DIR/${CHECKSUM_NAME}")
  echo "$HASH  $TMP_DIR/${ZIP_NAME}" > "$TMP_DIR/maple.check"

  gum spin --spinner dot --title "Verifying checksum …" \
    -- bash -c "sha256sum -c '$TMP_DIR/maple.check' --status" \
    || abort "Checksum verification failed for ${ZIP_NAME}."
  info "Checksum verified"

  gum spin --spinner dot \
    --title "Extracting ${ZIP_NAME} …" \
    -- unzip -q "$TMP_DIR/${ZIP_NAME}" -d "$TMP_DIR/maple_extracted"
  info "Archive extracted"

  keep_sudo_alive
  install_font_dir "$MAPLEMONO_DEST"

  MM_FILES=()
  while IFS= read -r -d '' f; do
    MM_FILES+=("$f")
  done < <(find "$TMP_DIR/maple_extracted" -type f \
    \( -iname "*.ttf" -o -iname "*.otf" \) -print0)

  [[ "${#MM_FILES[@]}" -eq 0 ]] && abort "No font files found inside ${ZIP_NAME}."

  gum spin --spinner meter \
    --title "Installing ${#MM_FILES[@]} Maple Mono font file(s) …" \
    -- bash -c "find '$TMP_DIR/maple_extracted' -type f \
      \( -iname '*.ttf' -o -iname '*.otf' \) \
      -exec sudo cp -v {} '$MAPLEMONO_DEST/' \;" &>/dev/null
  info "Fonts copied to ${MAPLEMONO_DEST}"

  echo "$LATEST_TAG" | sudo tee "$MAPLEMONO_VERSION_FILE" >/dev/null

  refresh_cache "$MAPLEMONO_DEST"
fi

# ════════════════════════════════════════════════════════
#  APORETIC
# ════════════════════════════════════════════════════════
if $INSTALL_APORETIC; then
  gum style --bold --margin "1 0" "── Aporetic ────────────────────────────"

  # ── Variant selection ─────────────────────────────────
  APORETIC_VARIANT=$(gum choose \
    --header "Which Aporetic variant do you want to install?" \
    "TTF          (hinted — recommended for most displays)" \
    "TTF-Unhinted (better for high-DPI / manual hinting)" \
    "Both")

  [[ -z "$APORETIC_VARIANT" ]] && {
    warn "No variant selected — skipping Aporetic."
    INSTALL_APORETIC=false
  }
fi

if $INSTALL_APORETIC; then
  case "$APORETIC_VARIANT" in
    TTF\ *)          AP_DIRS=("TTF") ;;
    TTF-Unhinted\ *) AP_DIRS=("TTF-Unhinted") ;;
    Both)            AP_DIRS=("TTF" "TTF-Unhinted") ;;
  esac

  gum confirm "Install Aporetic [${AP_DIRS[*]}] to ${APORETIC_DEST}?" || {
    warn "Skipping Aporetic."
    INSTALL_APORETIC=false
  }
fi

if $INSTALL_APORETIC; then
  gum spin --spinner dot --title "Cloning protesilaos/aporetic …" \
    -- git clone --depth=1 --quiet "$APORETIC_REPO" "$TMP_DIR/aporetic"
  info "Repository cloned"

  install_font_dir "$APORETIC_DEST"

  AP_TOTAL=0

  # ── Family dirs present in the repo ───────────────────
  AP_FAMILIES=()
  while IFS= read -r -d '' d; do
    AP_FAMILIES+=("$d")
  done < <(find "$TMP_DIR/aporetic" -mindepth 1 -maxdepth 1 \
    -type d -name "aporetic-*" -print0 | sort -z)

  [[ "${#AP_FAMILIES[@]}" -eq 0 ]] && abort "No aporetic-* family directories found in repo."

  for family_dir in "${AP_FAMILIES[@]}"; do
    family_name="$(basename "$family_dir")"

    for variant in "${AP_DIRS[@]}"; do
      src_dir="${family_dir}/${variant}"

      # Skip gracefully if this variant doesn't exist for a family
      [[ -d "$src_dir" ]] || {
        warn "  ${family_name}/${variant} not found — skipping."
        continue
      }

      # Mirror structure: Aporetic-Super-Family/<family>/<variant>/
      dest_subdir="${APORETIC_DEST}/${family_name}/${variant}"
      sudo mkdir -p "$dest_subdir"

      # Count & copy
      file_count=0
      while IFS= read -r -d '' f; do
        sudo cp "$f" "$dest_subdir/"
        (( file_count++ )) || true
      done < <(find "$src_dir" -maxdepth 1 -type f \
        \( -iname "*.ttf" -o -iname "*.otf" \) -print0)

      (( AP_TOTAL += file_count )) || true
      info "  ${family_name}/${variant}  →  ${file_count} file(s)"
    done
  done

  [[ "$AP_TOTAL" -eq 0 ]] && abort "No font files were installed for Aporetic."

  refresh_cache "$APORETIC_DEST"
fi

# ════════════════════════════════════════════════════════
#  SUMMARY
# ════════════════════════════════════════════════════════
SUMMARY_LINES=()
if $INSTALL_SPACEMONO; then
  SM_COUNT=$(fc-list | grep -ic 'SpaceMono\|Space Mono' || true)
  SUMMARY_LINES+=("✓ Space Mono  — ${SM_COUNT} face(s) registered")
fi
if $INSTALL_MAPLEMONO; then
  MM_COUNT=$(fc-list | grep -ic 'MapleMono\|Maple Mono' || true)
  SUMMARY_LINES+=("✓ Maple Mono ${LATEST_TAG}  — ${MM_COUNT} face(s) registered")
fi
if $INSTALL_APORETIC; then
  AP_COUNT=$(fc-list | grep -ic 'Aporetic' || true)
  SUMMARY_LINES+=("✓ Aporetic [${AP_DIRS[*]}]  — ${AP_COUNT} face(s) registered")
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

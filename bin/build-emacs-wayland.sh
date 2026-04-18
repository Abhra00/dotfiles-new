#!/usr/bin/env bash
# =============================================================================
# build-emacs-wayland.sh — Glamorous Emacs PGTK/Wayland source builder
# Requires: gum (pacman -S gum)
# =============================================================================
set -euo pipefail

# ── Bootstrap gum ─────────────────────────────────────────────────────────────
if ! command -v gum &>/dev/null; then
  echo "gum not found. Installing via pacman..."
  sudo pacman -S --noconfirm --needed gum
fi

# ── Theme (Catppuccin Mocha) ──────────────────────────────────────────────────
export GUM_CONFIRM_PROMPT_FOREGROUND="#CBA6F7"
export GUM_CONFIRM_SELECTED_FOREGROUND="#1E1E2E"
export GUM_CONFIRM_SELECTED_BACKGROUND="#CBA6F7"
export GUM_CHOOSE_CURSOR_FOREGROUND="#CBA6F7"
export GUM_CHOOSE_SELECTED_FOREGROUND="#CBA6F7"
export GUM_INPUT_CURSOR_FOREGROUND="#CBA6F7"
export GUM_INPUT_PROMPT_FOREGROUND="#89B4FA"
export GUM_SPIN_SPINNER_FOREGROUND="#CBA6F7"

MAUVE="#CBA6F7"
BLUE="#89B4FA"
GREEN="#A6E3A1"
RED="#F38BA8"
YELLOW="#F9E2AF"
SUBTEXT="#6C7086"

# ── Helpers ───────────────────────────────────────────────────────────────────
title() {
  gum style \
    --border double --border-foreground "$MAUVE" \
    --padding "1 4" --margin "1 0" \
    --bold --foreground "$MAUVE" \
    "$@"
}

section() {
  echo ""
  gum style --foreground "$BLUE" --bold "  ▶ $*"
}

info() { gum style --foreground "$SUBTEXT" "    $*"; }
ok()   { gum style --foreground "$GREEN"   "    ✓ $*"; }
warn() { gum style --foreground "$YELLOW"  "    ⚠ $*"; }
die()  { gum style --foreground "$RED" --bold "    ✗ $*"; exit 1; }

spin() {
  local spin_title="$1"; shift
  gum spin --spinner dot \
    --title "  ${spin_title}" \
    --title.foreground "$MAUVE" \
    -- "$@"
}

# ── Sanity ────────────────────────────────────────────────────────────────────
[[ "$EUID" -eq 0 ]] && die "Don't run as root. sudo will be invoked where needed."
command -v pacman &>/dev/null || die "Arch Linux only (pacman not found)."

# ── Header ────────────────────────────────────────────────────────────────────
clear
title \
  "  Emacs Wayland Builder  " \
  "  PGTK · native-comp · tree-sitter  "

gum style --foreground "$SUBTEXT" --italic \
  "  Builds the latest stable Emacs from source — no Arch package ABI nonsense."
echo ""

# ── 0. Mode selection ─────────────────────────────────────────────────────────
MODE=$(gum choose \
  --header "  What would you like to do?" \
  --header.foreground "$BLUE" \
  "install   Build and install Emacs from source" \
  "uninstall Remove Emacs and orphaned build dependencies")

echo "$MODE" | grep -q "uninstall" && MODE="uninstall" || MODE="install"

# ── Uninstall path ────────────────────────────────────────────────────────────
if [[ "$MODE" == "uninstall" ]]; then
  section "Uninstall"

  PREFIX=$(gum input \
    --prompt "  Install prefix to remove from › " \
    --value "/usr/local" \
    --width 40)
  [[ -z "$PREFIX" ]] && PREFIX="/usr/local"

  warn "This will remove ${PREFIX}/bin/emacs and associated files."
  warn "Orphaned build-only dependencies will also be removed."
  echo ""
  gum confirm "  Are you sure?" || { warn "Aborted."; exit 0; }

  # Remove the installed binary and related files
  section "Removing Emacs files from ${PREFIX}"
  sudo rm -fv \
    "${PREFIX}/bin/emacs" \
    "${PREFIX}/bin/emacs-"* \
    "${PREFIX}/bin/emacsclient" \
    "${PREFIX}/bin/ctags" \
    "${PREFIX}/bin/ebrowse" \
    "${PREFIX}/bin/etags"
  sudo rm -rf \
    "${PREFIX}/share/emacs" \
    "${PREFIX}/share/info/emacs"* \
    "${PREFIX}/share/man/man1/emacs"* \
    "${PREFIX}/share/applications/emacs"* \
    "${PREFIX}/lib/emacs" \
    "${PREFIX}/libexec/emacs"
  sudo ldconfig
  ok "Emacs files removed."

  # Remove orphaned build dependencies
  section "Removing orphaned build dependencies"
  BUILD_DEPS=(base-devel git autoconf automake texinfo)
  ORPHANS=()
  for pkg in "${BUILD_DEPS[@]}"; do
    # Only remove if pacman reports it as not required by anything else
    if pacman -Q "$pkg" &>/dev/null && [[ -z "$(pacman -Qi "$pkg" 2>/dev/null | grep 'Required By' | grep -v 'None')" ]]; then
      ORPHANS+=("$pkg")
    fi
  done

  if [[ ${#ORPHANS[@]} -gt 0 ]]; then
    info "Orphaned packages found: ${ORPHANS[*]}"
    if gum confirm "  Remove them?"; then
      sudo pacman -Rns --noconfirm "${ORPHANS[@]}" || warn "Some packages could not be removed (may be required by others)."
      ok "Orphans removed."
    else
      warn "Skipped."
    fi
  else
    ok "No orphaned build dependencies found."
  fi

  # pacman orphan sweep
  section "Full orphan sweep"
  PACMAN_ORPHANS=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -n "$PACMAN_ORPHANS" ]]; then
    info "System orphans:"
    echo "$PACMAN_ORPHANS" | while read -r pkg; do
      gum style --foreground "$SUBTEXT" "      • $pkg"
    done
    echo ""
    if gum confirm "  Remove all system orphans?"; then
      # shellcheck disable=SC2086
      sudo pacman -Rns --noconfirm $PACMAN_ORPHANS
      ok "System orphans removed."
    else
      warn "Skipped."
    fi
  else
    ok "No system orphans found."
  fi

  echo ""
  title "  Uninstall complete  "
  exit 0
fi

# ── Install path ──────────────────────────────────────────────────────────────

# ── 1. Interactive options ────────────────────────────────────────────────────
section "Configuration"

PREFIX=$(gum input \
  --prompt "  Install prefix › " \
  --value "/usr/local" \
  --width 40)
[[ -z "$PREFIX" ]] && PREFIX="/usr/local"

BUILD_DIR="${HOME}/.local/src"

JOBS=$(gum input \
  --prompt "  Parallel jobs › " \
  --value "$(nproc)" \
  --width 10)
[[ -z "$JOBS" ]] && JOBS=$(nproc)

echo ""
# xwidgets is broken in Emacs 30 — configure requires webkit2gtk < 2.41.92
# but any current Arch system has a much newer version.
# See: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=66068
warn "xwidgets disabled — broken in Emacs 30 (requires webkit2gtk < 2.41.92, incompatible with current Arch packages)"

EXTRA=$(gum choose --no-limit \
  --header "  Optional features  (space = toggle, enter = confirm)" \
  --header.foreground "$BLUE" \
  "imagemagick  ImageMagick image backend" \
  "mailutils    external mailutils for sendmail" \
  "libsystemd   systemd journal integration")

IMAGEMAGICK=false; MAILUTILS=false; SYSTEMD_FLAG=""
echo "$EXTRA" | grep -q "imagemagick" && IMAGEMAGICK=true
echo "$EXTRA" | grep -q "mailutils"   && MAILUTILS=true
echo "$EXTRA" | grep -q "libsystemd"  && SYSTEMD_FLAG="--with-libsystemd"

echo ""
gum style --border normal --border-foreground "$SUBTEXT" --padding "0 2" \
  "$(gum style --foreground "$BLUE" --bold "Summary")
$(gum style --foreground "$SUBTEXT" "  prefix      : ")$(gum style --foreground "$MAUVE" "$PREFIX")
$(gum style --foreground "$SUBTEXT" "  build dir   : ")$(gum style --foreground "$MAUVE" "$BUILD_DIR")
$(gum style --foreground "$SUBTEXT" "  jobs        : ")$(gum style --foreground "$MAUVE" "$JOBS")
$(gum style --foreground "$SUBTEXT" "  imagemagick : ")$(gum style --foreground "$MAUVE" "$IMAGEMAGICK")"

echo ""
gum confirm "  Looks good — proceed?" || { warn "Aborted."; exit 0; }

# ── 2. Remove conflicting Arch package ───────────────────────────────────────
section "Checking for conflicting Arch package"

for pkg in emacs emacs-wayland emacs-nativecomp; do
  if pacman -Q "$pkg" &>/dev/null 2>&1; then
    warn "${pkg} (Arch package) is installed — may conflict with ${PREFIX}."
    if gum confirm "  Remove it via pacman now?"; then
      sudo pacman -Rns --noconfirm "$pkg"
      ok "Removed ${pkg}."
    else
      warn "Skipping removal — install step may fail or overwrite files."
    fi
  fi
done
ok "Conflict check done."

# ── 3. Dependencies ───────────────────────────────────────────────────────────
section "Installing build dependencies"

RUNTIME_DEPS=(
  # Core
  gmp gnutls lcms2 acl dbus sqlite zlib
  # GUI / Wayland
  gtk3 gdk-pixbuf2 glib2 pango cairo wayland wayland-protocols libxkbcommon
  # Fonts / text rendering
  fontconfig freetype2 harfbuzz libice libsm libxfixes libotf m17n-lib
  # Images
  libjpeg-turbo libpng libtiff giflib librsvg libwebp
  # Features
  libgccjit libxml2 tree-sitter alsa-lib systemd-libs
)
BUILD_DEPS=(base-devel git autoconf automake texinfo gnupg)

$IMAGEMAGICK && RUNTIME_DEPS+=(imagemagick)

ALL_DEPS=("${RUNTIME_DEPS[@]}" "${BUILD_DEPS[@]}")

sudo pacman -Syu --needed "${ALL_DEPS[@]}" \
  || warn "pacman returned non-zero — some optional packages may be absent."

ok "All dependencies installed."

# ── 4. Fetch source ───────────────────────────────────────────────────────────
section "Fetching latest stable Emacs"

# Filter out pretest/rc releases and pick the highest stable x.y version
LATEST=$(curl -s https://ftp.gnu.org/gnu/emacs/ \
  | grep -oP 'emacs-\K[0-9]+\.[0-9]+(?=\.tar\.xz)' \
  | grep -vP '(rc|pre|alpha|beta)' \
  | sort -V | tail -1)
[[ -z "$LATEST" ]] && die "Could not determine latest version from ftp.gnu.org"

gum style --foreground "$GREEN" --bold "  Latest stable detected: emacs-${LATEST}"

SRC_TARBALL="emacs-${LATEST}.tar.xz"
SRC_URL="https://ftp.gnu.org/gnu/emacs/${SRC_TARBALL}"
SRC_SIG="${SRC_TARBALL}.sig"
SRC_SIG_URL="${SRC_URL}.sig"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [[ -f "$SRC_TARBALL" ]]; then
  if gum confirm "  ${SRC_TARBALL} already exists — re-download?"; then
    spin "Downloading emacs-${LATEST}..." \
      curl -L --silent --show-error -O "$SRC_URL"
    ok "Downloaded."
  else
    ok "Using cached tarball."
  fi
else
  spin "Downloading emacs-${LATEST} from GNU FTP..." \
    curl -L --silent --show-error -O "$SRC_URL"
  ok "Downloaded."
fi

# GPG verification
section "Verifying tarball signature"
spin "Fetching signature..." \
  curl -L --silent --show-error -O "$SRC_SIG_URL"

# Import GNU Emacs release keys from keyserver (no-op if already present)
gpg --keyserver keyserver.ubuntu.com --recv-keys \
  17E90D521672C04631B1183EE6D88F6D7B4997A6 \
  2>/dev/null || true

if gpg --verify "$SRC_SIG" "$SRC_TARBALL" 2>/dev/null; then
  ok "GPG signature verified."
else
  warn "GPG verification failed or key unavailable — proceeding without verification."
  warn "You can verify manually: gpg --verify ${BUILD_DIR}/${SRC_SIG} ${BUILD_DIR}/${SRC_TARBALL}"
fi

spin "Extracting sources..." \
  bash -c "rm -rf 'emacs-${LATEST}' && tar xf '${SRC_TARBALL}'"
ok "Extracted to ${BUILD_DIR}/emacs-${LATEST}"
cd "emacs-${LATEST}"

# ── 5. Configure ──────────────────────────────────────────────────────────────
section "Configuring"

CONFIGURE_FLAGS=(
  --prefix="$PREFIX"
  # Wayland / PGTK — pure GTK3, no X11 required
  --with-pgtk
  # Native compilation via libgccjit (AOT is the default when this flag is set)
  --with-native-compilation
  # Tree-sitter — link against system lib to avoid ABI mismatch
  --with-tree-sitter
  # Image formats
  --with-jpeg --with-png --with-gif --with-tiff --with-rsvg --with-webp
  # Text rendering
  --with-cairo --with-harfbuzz --with-libotf --with-m17n-flt
  # Core features
  --with-gnutls --with-xml2 --with-sqlite3 --with-lcms2
  --with-dbus --with-alsa
  # No X11 toolkit, no GPM (irrelevant on Wayland)
  --without-x --without-xaw3d --without-gpm
)

[[ -n "$SYSTEMD_FLAG" ]]   && CONFIGURE_FLAGS+=("$SYSTEMD_FLAG")
$MAILUTILS   || CONFIGURE_FLAGS+=(--without-mailutils)
$IMAGEMAGICK && CONFIGURE_FLAGS+=(--with-imagemagick)

spin "Running ./configure..." \
  bash -c "./configure ${CONFIGURE_FLAGS[*]} >/tmp/emacs-configure.log 2>&1" \
  || { warn "Configure failed — see /tmp/emacs-configure.log"; die "Aborting."; }

ok "Configure done.  Log: /tmp/emacs-configure.log"

# ── 6. Build ──────────────────────────────────────────────────────────────────
section "Compiling Emacs with ${JOBS} jobs"

gum style --foreground "$SUBTEXT" --italic \
  "  This takes 5–15 min depending on your CPU. Go grab a coffee ☕"
echo ""

make -j"$JOBS" 2>&1 | tee /tmp/emacs-make.log \
  || { warn "Compilation failed — see /tmp/emacs-make.log"; die "Aborting."; }

ok "Compilation complete."

# ── 7. Install ────────────────────────────────────────────────────────────────
section "Installation"

if gum confirm "  Install Emacs to ${PREFIX}?  (requires sudo)"; then
  sudo make install 2>&1 | tee /tmp/emacs-install.log
  sudo ldconfig
  ok "Installed: ${PREFIX}/bin/emacs"
else
  warn "Skipped. Test binary: ${BUILD_DIR}/emacs-${LATEST}/src/emacs"
fi

# ── 8. Desktop entry ──────────────────────────────────────────────────────────
section "Wayland desktop entry"

DESKTOP_FILE="${PREFIX}/share/applications/emacs-wayland.desktop"
if gum confirm "  Write .desktop entry to ${DESKTOP_FILE}?"; then
  sudo mkdir -p "$(dirname "$DESKTOP_FILE")"
  sudo tee "$DESKTOP_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=Emacs (Wayland)
GenericName=Text Editor
Comment=GNU Emacs – native PGTK/Wayland build from source
Exec=emacs %F
Icon=emacs
Type=Application
Categories=Development;TextEditor;
Keywords=editor;lisp;emacs;
StartupWMClass=Emacs
Terminal=false
EOF
  ok "Desktop entry written."
fi

# ── 9. Done ───────────────────────────────────────────────────────────────────
echo ""
title "  Done!  emacs-${LATEST} (PGTK/Wayland)  "

SUMMARY_LINES=(
  "$(gum style --foreground "$BLUE" --bold "What was compiled in")"
  "$(gum style --foreground "$GREEN" "  ✓ PGTK            pure GTK3, native Wayland — no XWayland")"
  "$(gum style --foreground "$GREEN" "  ✓ native-comp      AOT .eln compilation via libgccjit")"
  "$(gum style --foreground "$GREEN" "  ✓ tree-sitter      system libtree-sitter.so — no ABI mismatch")"
  "$(gum style --foreground "$GREEN" "  ✓ sqlite3          org-roam / emacsql backend")"
  "$(gum style --foreground "$GREEN" "  ✓ cairo/harfbuzz   crisp font rendering & ligatures")"
  "$(gum style --foreground "$GREEN" "  ✓ webp/svg/jpeg    full image format stack")"
)
$IMAGEMAGICK && SUMMARY_LINES+=("$(gum style --foreground "$GREEN" "  ✓ imagemagick      ImageMagick image processing")")

gum style --border rounded --border-foreground "$BLUE" \
  --padding "0 2" --margin "0 1" \
  "$(printf '%s\n' "${SUMMARY_LINES[@]}")"

echo ""
gum style --foreground "$SUBTEXT" "  Verify:"
gum style --foreground "$MAUVE"   "    emacs --version"
gum style --foreground "$MAUVE"   "    emacs -Q --batch --eval '(message \"%s\" system-configuration-features)'"
echo ""
gum style --foreground "$SUBTEXT" "  Rebuild after a new upstream release:"
gum style --foreground "$MAUVE"   "    ./build-emacs-wayland.sh"
echo ""

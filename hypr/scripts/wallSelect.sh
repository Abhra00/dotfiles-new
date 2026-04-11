#!/usr/bin/env bash
#  ┓ ┏┏┓┓ ┓ ┏┓┏┓┓ ┏┓┏┓┏┳┓
#  ┃┃┃┣┫┃ ┃ ┗┓┣ ┃ ┣ ┃  ┃
#  ┗┻┛┛┗┗┛┗┛┗┛┗┛┗┛┗┛┗┛ ┻
#

# Thank you gh0stzk for the script 🤲 means a lot
# Copyright (C) 2021-2025 gh0stzk <z0mbi3.zk@protonmail.com>
# Licensed under GPL-3.0 license

# WallSelect - Dynamic wallpaper selector with intelligent caching system
# Features:
#   ✔ Multi-monitor support with scaling
#   ✔ Auto-updating menu (add/delete wallpapers without restart)
#   ✔ Parallel image processing (optimized CPU usage)
#   ✔ XXHash64 checksum verification for cache integrity
#   ✔ Orphaned cache detection and cleanup
#   ✔ Adaptive icon sizing based on screen resolution
#   ✔ Lockfile system for safe concurrent operations
#   ✔ Handle gif files separately
#   ✔ Rofi integration with theme support
#   ✔ Dynamic theming using pywal
#
#
# Dependencies:
#   → Core: hyprland, rofi, jq, xxhsum (xxhash)
#   → Media: hyprpaper, imagemagick
#   → GNU: findutils, coreutils, bc

# Set variables
wall_dir="$HOME/Pictures/Wallpapers"
cacheDir="$HOME/.cache/wallcache"
scriptsDir="$HOME/.config/hypr/scripts"
fit_mode="cover"
rofi_theme="$HOME/.config/rofi/wallSelect.rasi"

# Create cache dir if not exists
[ -d "$cacheDir" ] || mkdir -p "$cacheDir"

# Get focused monitor
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Rofi command
rofi_command="rofi -i -show -dmenu -theme ${rofi_theme}"

# Detect number of cores and set a sensible number of jobs
get_optimal_jobs() {
    local cores=$(nproc)
    ((cores <= 2)) && echo 2 || echo $(((cores > 4) ? 4 : cores - 1))
}

PARALLEL_JOBS=$(get_optimal_jobs)

process_image() {
    local imagen="$1"
    local nombre_archivo=$(basename "$imagen")
    local cache_file="${cacheDir}/${nombre_archivo}"
    local xxh64_file="${cacheDir}/.${nombre_archivo}.xxh64"
    local lock_file="${cacheDir}/.lock_${nombre_archivo}"

    local current_xxh64=$(xxh64sum "$imagen" | cut -d' ' -f1)

    (
        flock -x -w 10 200 || exit 1
        if [ ! -f "$cache_file" ] || [ ! -f "$xxh64_file" ] || [ "$current_xxh64" != "$(cat "$xxh64_file" 2>/dev/null)" ]; then
            magick "$imagen" -resize 500x500^ -gravity center -extent 500x500 "$cache_file"
            echo "$current_xxh64" >"$xxh64_file"
        fi
        # Clean the lock file after processing
        rm -f "$lock_file"
    ) 200>"$lock_file"
}

# Export variables & functions
export -f process_image
export wall_dir cacheDir

# Clean old stale locks (older than 1 minute) before starting
find "${cacheDir}" -name ".lock_*" -type f -mmin +1 -delete 2>/dev/null || true

# Process files in parallel
find "$wall_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0 |
    xargs -0 -P "$PARALLEL_JOBS" -I {} bash -c 'process_image "{}"'

# Clean orphaned cache files and their checksums
for cached in "$cacheDir"/*; do
    [ -f "$cached" ] || continue
    # Skip checksum and lock files
    [[ "$(basename "$cached")" =~ ^\. ]] && continue
    
    original="${wall_dir}/$(basename "$cached")"
    if [ ! -f "$original" ]; then
        nombre_archivo=$(basename "$cached")
        rm -f "$cached" \
            "${cacheDir}/.${nombre_archivo}.xxh64" \
            "${cacheDir}/.lock_${nombre_archivo}"
    fi
done

# Clean orphaned checksum files
for xxh64_file in "$cacheDir"/.*.xxh64; do
    [ -f "$xxh64_file" ] || continue
    nombre_archivo=$(basename "$xxh64_file" | sed 's/^\.//; s/\.xxh64$//')
    if [ ! -f "${cacheDir}/${nombre_archivo}" ]; then
        rm -f "$xxh64_file"
    fi
done

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
fi

# Launch rofi
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0 |
    xargs -0 basename -a |
    LC_ALL=C sort -V |
    while IFS= read -r A; do
        if [[ "$A" =~ \.gif$ ]]; then
            printf "%s\n" "$A" # Handle gifs by showing only file name
        else
            printf '%s\x00icon\x1f%s/%s\n' "$A" "${cacheDir}" "$A" # Non-gif files with icon convention
        fi
    done | $rofi_command)

# Exit immediately if there is no selection
[[ -z "${wall_selection}" ]] && exit 0

# Full wallpaper path
wallpaper_path="${wall_dir}/${wall_selection}"

# Validate wallpaper exists
[[ -f "$wallpaper_path" ]] || exit 1

# Ensure hyprpaper is running
if ! pgrep -x "hyprpaper" >/dev/null; then
    notify-send -e -h string:x-canonical-private-synchronous:hyprpaper_notif "🚀 Starting hyprpaper..."
    setsid -f hyprpaper
    sleep 0.5 # Wait a bit to ensure the socket is ready
else
    notify-send -e -h string:x-canonical-private-synchronous:hyprpaper_notif "✅ hyprpaper is already running"
fi

# Set the wallpaper
hyprctl hyprpaper wallpaper "${focused_monitor},${wallpaper_path},${fit_mode}"

# Symlink the wallpaper in global-wallpaper file
sleep 0.5
ln -sf "$wallpaper_path" "$HOME/.local/share/bg"

# Run theme script
"$scriptsDir/magick.sh" "✨ WallMagick ✨"

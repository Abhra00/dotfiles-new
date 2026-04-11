#!/usr/bin/env bash
# ┏┓┓┏┏┓┓ ┏┓  ┓ ┏┏┓┓ ┓
# ┃ ┗┫┃ ┃ ┣ ━━┃┃┃┣┫┃ ┃
# ┗┛┗┛┗┛┗┛┗┛  ┗┻┛┛┗┗┛┗┛

# Set variables
wall_dir="$HOME/Pictures/Wallpapers"
scriptsDir="$HOME/.config/hypr/scripts"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
fit_mode="cover"

# Get list of wallpapers, sorted
wall_list=($(find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort -V))

# Check if wallpapers exist
if [[ ${#wall_list[@]} -eq 0 ]]; then
    notify-send -e -h string:x-canonical-private-synchronous:hyprpaper_notif "❌ No wallpapers found in $wall_dir"
    exit 1
fi

# File to store last wallpaper index
index_file="$HOME/.cache/.last_wallpaper_index"

# Read last index, default to -1 if file doesn't exist
if [[ -f "$index_file" ]]; then
    last_index=$(<"$index_file")
else
    last_index=-1
fi

# Compute next index (loop back to 0)
next_index=$(( (last_index + 1) % ${#wall_list[@]} ))

# Select wallpaper
wall="${wall_list[$next_index]}"

# Save the index for next run
echo "$next_index" > "$index_file"

# Ensure hyprpaper is running
if ! pgrep -x "hyprpaper" >/dev/null; then
    notify-send -e -h string:x-canonical-private-synchronous:hyprpaper_notif "🚀 Starting hyprpaper..."
    setsid -f hyprpaper >/dev/null 2>&1 &
    sleep 0.5
else
    notify-send -e -h string:x-canonical-private-synchronous:hyprpaper_notif "✅ hyprpaper is already running"
fi

# Preload and set wallpaper
hyprctl hyprpaper wallpaper "$focused_monitor,$wall,$fit_mode"

# Symlink the wallpaper in global-wallpaper file
sleep 0.5
ln -sf "$wall" "$HOME/.local/share/bg"

# Run the magic script
sleep 0.2
"$scriptsDir/magick.sh" "✨ Sequential Wallpaper ✨"

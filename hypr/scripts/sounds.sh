#!/usr/bin/env bash
#  ┏┓┏┓┳┳┳┓┳┓┏┓
#  ┗┓┃┃┃┃┃┃┃┃┗┓
#  ┗┛┗┛┗┛┛┗┻┛┗┛
#

# Variables
theme="freedesktop"
mute=false
muteScreenshots=false

[[ "$mute" = true ]] && exit 0

case "$1" in
--screenshot)
    [[ "$muteScreenshots" = true ]] && exit 0
    soundoption="screen-capture.*"
    ;;
--countdown)
    [[ "$muteScreenshots" = true ]] && exit 0
    soundoption="bell.*"
    ;;
--error)
    [[ "$muteScreenshots" = true ]] && exit 0
    soundoption="dialog-error.*"
    ;;
*)
    echo "Available sounds: --screenshot, --countdown, --error"
    exit 0
    ;;
esac

userDIR="$HOME/.local/share/sounds"
systemDIR="/usr/share/sounds"
defaultTheme="freedesktop"

sDIR="$systemDIR/$defaultTheme"
[[ -d "$userDIR/$theme" ]] && sDIR="$userDIR/$theme" || [[ -d "$systemDIR/$theme" ]] && sDIR="$systemDIR/$theme"

iTheme=$(grep -i "inherits" "$sDIR/index.theme" | cut -d "=" -f 2)
iDIR="$sDIR/../$iTheme"

# Find sound file once using a single find with multiple paths
sound_file=$(find "$sDIR/stereo" "$iDIR/stereo" "$userDIR/$defaultTheme/stereo" "$systemDIR/$defaultTheme/stereo" \
    -name "$soundoption" -print -quit 2>/dev/null)

if [[ ! -f "$sound_file" ]]; then
    echo "Error: Sound file not found."
    exit 1
fi

# Non-blocking playback
paplay "$sound_file" &

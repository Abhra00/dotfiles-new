#!/usr/bin/env bash
# ┓┏┏┓┓ ┳┳┳┳┓┏┓  ┏┓┓┏┏┓┳┓┏┳┓  ┓ ┏┏┓┏┳┓┏┓┓┏┏┓┳┓
# ┃┃┃┃┃ ┃┃┃┃┃┣ ━━┣ ┃┃┣ ┃┃ ┃ ━━┃┃┃┣┫ ┃ ┃ ┣┫┣ ┣┫
# ┗┛┗┛┗┛┗┛┛ ┗┗┛  ┗┛┗┛┗┛┛┗ ┻   ┗┻┛┛┗ ┻ ┗┛┛┗┗┛┛┗
#
iDIR="$HOME/.config/mako/assets"
last_port=""

pactl subscribe | grep --line-buffered "on sink" | while read -r _; do
    port=$(pactl list sinks | grep "Active Port" | awk '{print $NF}')

    [ "$port" = "$last_port" ] && continue
    last_port="$port"

    if echo "$port" | grep -qi "headphones"; then
        icon="$iDIR/headphone-high.png"
        label="Headphones"
    else
        icon="$iDIR/volume-high.svg"
        label="Speakers"
    fi

    notify-send \
        -a "VolumeOSD" \
        -i "$icon" \
        -h "string:x-canonical-private-synchronous:volume-osd" \
        -t 2000 \
        "Audio Output" "$label"
done

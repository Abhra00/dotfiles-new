#!/usr/bin/env bash
# ┳┓┳┓┳┏┓┓┏┏┳┓┳┓┏┓┏┓┏┓  ┏┓┏┓┳┓
# ┣┫┣┫┃┃┓┣┫ ┃ ┃┃┣ ┗┓┗┓━━┃┃┗┓┃┃
# ┻┛┛┗┻┗┛┛┗ ┻ ┛┗┗┛┗┛┗┛  ┗┛┗┛┻┛
#

iDIR="$HOME/.config/mako/assets"

# ── get brightness % ──────────────────────────────────────────────────────────
get_brightness() {
    local current max
    current=$(brightnessctl get)
    max=$(brightnessctl max)
    echo $(( current * 100 / max ))
}

# ── pick icon (8 even bands) ──────────────────────────────────────────────────
get_icon() {
    local pct="$1"
    local name

    if   [ "$pct" -eq 0 ];  then name="brightness-empty"
    elif [ "$pct" -le 13 ]; then name="brightness-1"
    elif [ "$pct" -le 25 ]; then name="brightness-2"
    elif [ "$pct" -le 38 ]; then name="brightness-3"
    elif [ "$pct" -le 50 ]; then name="brightness-4"
    elif [ "$pct" -le 63 ]; then name="brightness-5"
    elif [ "$pct" -le 75 ]; then name="brightness-6"
    else                         name="brightness-full"
    fi

    echo "$iDIR/${name}.svg"
}

# ── notification ──────────────────────────────────────────────────────────────
send_notif() {
    local pct icon
    pct=$(get_brightness)
    icon=$(get_icon "$pct")

    notify-send \
        -a "BrightnessOSD" \
        -i "$icon" \
        -h "string:x-canonical-private-synchronous:brightness-osd" \
        -h "int:value:${pct}" \
        -t 2000 \
        "Brightness" "${pct}%"
}

# ── dispatch ──────────────────────────────────────────────────────────────────
case "$1" in
    up)   brightnessctl set 5%+ -q; send_notif ;;
    down) brightnessctl set 5%- -q; send_notif ;;
    set)  brightnessctl set "${2}%" -q; send_notif ;;
    info) send_notif ;;
    *)    echo "Usage: $0 up|down|set <value>|info"; exit 1 ;;
esac

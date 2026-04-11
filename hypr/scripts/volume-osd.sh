#!/usr/bin/env bash
# ┓┏┏┓┓ ┳┳┳┳┓┏┓  ┏┓┏┓┳┓  
# ┃┃┃┃┃ ┃┃┃┃┃┣ ━━┃┃┗┓┃┃  
# ┗┛┗┛┗┛┗┛┛ ┗┗┛  ┗┛┗┛┻┛  
# 

STEP=5
iDIR="$HOME/.config/mako/assets"

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{
        vol = int($2 * 100)
        if ($3 == "[MUTED]") print vol " muted"
        else print vol
    }'
}

get_mic_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{
        vol = int($2 * 100)
        if ($3 == "[MUTED]") print vol " muted"
        else print vol
    }'
}

pick_vol_icon() {
    local vol="$1"
    if   [ "$vol" -eq 0 ];  then echo "$iDIR/volume-mute.svg"
    elif [ "$vol" -lt 34 ]; then echo "$iDIR/volume-low.svg"
    elif [ "$vol" -lt 67 ]; then echo "$iDIR/volume-medium.svg"
    else                         echo "$iDIR/volume-high.svg"
    fi
}

send_vol_notif() {
    local vol="$1" muted="$2" icon label
    if [ "$muted" = "muted" ]; then
        icon="$iDIR/volume-mute.svg"
        label="Muted"
    else
        icon=$(pick_vol_icon "$vol")
        label="${vol}%"
    fi
    notify-send \
        -a "VolumeOSD" \
        -i "$icon" \
        -h "string:x-canonical-private-synchronous:volume-osd" \
        -h "int:value:${vol}" \
        -t 2000 \
        "Volume" "$label"
}

case "$1" in
    up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ ${STEP}%+
        read -r vol muted <<< "$(get_volume)"
        send_vol_notif "$vol" "$muted"
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ ${STEP}%-
        read -r vol muted <<< "$(get_volume)"
        send_vol_notif "$vol" "$muted"
        ;;
    mute-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        read -r vol muted <<< "$(get_volume)"
        send_vol_notif "$vol" "$muted"
        ;;
    mic-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        read -r vol muted <<< "$(get_mic_volume)"
        if [ "$muted" = "muted" ]; then
            icon="$iDIR/mic-mute.svg"
            label="Muted"
        else
            icon="$iDIR/mic.svg"
            label="Active"
        fi
        notify-send \
            -a "VolumeOSD" \
            -i "$icon" \
            -h "string:x-canonical-private-synchronous:mic-osd" \
            -t 2000 \
            "Microphone" "$label"
        ;;
esac

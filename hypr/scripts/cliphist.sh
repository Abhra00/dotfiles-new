#!/usr/bin/env bash
#  ┏┓┓ ┳┏┓┓┏┳┏┓┏┳┓
#  ┃ ┃ ┃┃┃┣┫┃┗┓ ┃
#  ┗┛┗┛┻┣┛┛┗┻┗┛ ┻
#

# If rofi already open → close it
if pidof rofi > /dev/null; then
    pkill rofi
fi

# Launch menu
while true; do
    result=$(
        rofi -i -dmenu \
            -p "" \
            -theme ~/.config/rofi/cliphist.rasi \
            -theme-str 'entry { placeholder: "Type to filter"; }' \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -kb-custom-3 "Alt-p" \
            < <(cliphist list)
    )

    ret=$?

    case "$ret" in
        1) exit ;;
        10) cliphist delete <<< "$result"; continue ;;
        11) cliphist wipe; continue ;;
        12)
            if [[ "$result" == *"[[ binary data"* ]]; then
                tmp="/tmp/cliphist_preview.png"
                cliphist decode <<< "$result" > "$tmp"
                notify-send -h int:transient:1 -a "Cliphist" "Preview" "$tmp" -i "$tmp"
            else
                notify-send -h int:transient:1 -a "Cliphist" "Preview" "$(cliphist decode <<< "$result")"
            fi
            continue
            ;;
    esac

    [ -z "$result" ] && continue

    if [[ "$result" == *"[[ binary data"* ]]; then
        tmp="/tmp/cliphist_copy.png"
        cliphist decode <<< "$result" > "$tmp"
        wl-copy < "$tmp"
        notify-send -h int:transient:1 -a "Cliphist" "Clipboard" "Image Copied" -i "$tmp"
    else
        cliphist decode <<< "$result" | wl-copy
        notify-send -h int:transient:1 -a "Cliphist" "Clipboard" "Text Copied" -i "$HOME/.config/swaync/assets/bell.png"
    fi

    exit
done

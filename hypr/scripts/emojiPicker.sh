#!/usr/bin/env bash
# ┏┓┳┳┓┏┓┏┳┳  ┏┓┳┏┓┓┏┓┏┓┳┓
# ┣ ┃┃┃┃┃ ┃┃━━┃┃┃┃ ┃┫ ┣ ┣┫
# ┗┛┛ ┗┗┛┗┛┻  ┣┛┻┗┛┛┗┛┗┛┛┗

# Set variables
EMOJI_DATA="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/data/emoji.db"
MODE="${1:-both}"
ROFI_THEME="$HOME/.config/rofi/emojiPicker.rasi"

# Get the emoji menu
emoji=$(awk '{print $1 "\t" substr($0, index($0,$2))}' "$EMOJI_DATA" | \
        rofi -dmenu -i -matching fuzzy -sorting-method fzf \
        -kb-move-char-back "" \
        -kb-move-char-forward "" \
        -kb-row-left "Left" \
        -kb-row-right "Right" \
        -no-custom -theme "$ROFI_THEME" -format 's' -display-columns 1 | \
        cut -f1)


# Options
case "$MODE" in
    type)
        wtype "${emoji}" || wl-copy "${emoji}"
        ;;
    copy)
        wl-copy "${emoji}"
        ;;
    both)
        wtype "${emoji}" || true
        wl-copy "${emoji}"
        ;;
    *)
        echo "Usage: $0 [type|copy|both]"
        exit 1
        ;;
esac

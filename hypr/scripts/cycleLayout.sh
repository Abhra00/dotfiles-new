#!/usr/bin/env bash
# ┏┓┓┏┏┓┓ ┏┓  ┓ ┏┓┓┏┏┓┳┳┏┳┓
# ┃ ┗┫┃ ┃ ┣ ━━┃ ┣┫┗┫┃┃┃┃ ┃ 
# ┗┛┗┛┗┛┗┛┗┛  ┗┛┛┗┗┛┗┛┗┛ ┻ 


# --- Icon base path ---
iDIR="$HOME/.config/mako/assets"

# --- Layout cycle order ---
LAYOUTS=("dwindle" "master" "scrolling")
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-layout.state"

# --- Read current layout from state file ---
if [[ -f "$STATE_FILE" ]]; then
    CURRENT=$(cat "$STATE_FILE")
else
    # Auto-detect from hyprland if state file is missing
    CURRENT=$(hyprctl getoption general:layout -j 2>/dev/null | jq -r '.str' 2>/dev/null || echo "dwindle")
fi

# --- Find index of current layout and pick next ---
NEXT=""
for i in "${!LAYOUTS[@]}"; do
    if [[ "${LAYOUTS[$i]}" == "$CURRENT" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#LAYOUTS[@]} ))
        NEXT="${LAYOUTS[$NEXT_INDEX]}"
        break
    fi
done

# Fallback in case state file had a stale/unknown value
if [[ -z "$NEXT" ]]; then
    NEXT="dwindle"
fi

# --- Apply layout ---
hyprctl keyword general:layout "$NEXT"

# --- Save state ---
echo "$NEXT" > "$STATE_FILE"

# --- Map layout → label + icon ---
case "$NEXT" in
    dwindle)   LABEL="Dwindle"      ; ICON="$iDIR/dwindle-layout.svg"      ;;
    master)    LABEL="Master Stack" ; ICON="$iDIR/master-stack-layout.svg"  ;;
    scrolling) LABEL="Scrolling"    ; ICON="$iDIR/scrolling-layout.svg"     ;;
    *)         LABEL="$NEXT"        ; ICON=""                                ;;
esac

# --- Send OSD notification ---
# -h "string:x-canonical-private-string:layout-osd"
#    Tells OSD-aware daemons (dunst/mako) to treat this as a transient
#    overlay, skipping notification history and using centered OSD style.
notify-send \
    --app-name="LayoutOSD" \
    --urgency=normal \
    --expire-time=1800 \
    --icon="$ICON" \
    -e -h "string:x-canonical-private-synchronous:layout-osd" \
    "Layout: ${LABEL}"

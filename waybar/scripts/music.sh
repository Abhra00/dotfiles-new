#!/usr/bin/env bash
# ┳┳┓┳┳┏┓┳┏┓
# ┃┃┃┃┃┗┓┃┃ 
# ┛ ┗┗┛┗┛┻┗┛
#

# ── Configuration ─────────────────────────────────────────────────────────────
MAX_WIDTH=25          # Visible characters before scrolling kicks in
SCROLL_SPEED=1        # Characters to scroll per tick
VIZ_BARS=5            # Number of visualizer bars
SLEEP_INTERVAL=0.5    # Seconds between frames (~2 FPS).
                      # ⚠️ Keep >= 0.5 — faster updates can break Waybar tooltips globally
                      # due to known Waybar update/refresh limitations.
# ──────────────────────────────────────────────────────────────────────────────

# Bar characters: index 0 (shortest) → 7 (tallest)
BAR_CHARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# 32 smooth frames — each bar moves only ±1 level between frames
FRAMES=(
    "1 3 5 3 1"
    "1 3 6 4 1"
    "2 4 6 4 2"
    "2 4 7 5 2"
    "3 5 7 5 3"
    "3 5 7 6 3"
    "4 6 6 6 4"
    "4 6 5 7 4"
    "5 7 5 7 5"
    "5 7 4 6 5"
    "6 6 4 6 6"
    "6 6 3 5 6"
    "7 5 3 5 7"
    "7 5 2 4 7"
    "6 4 2 4 6"
    "6 4 1 3 6"
    "5 3 1 3 5"
    "5 3 2 4 5"
    "4 4 2 4 4"
    "4 4 3 5 4"
    "3 5 3 5 3"
    "3 5 4 6 3"
    "2 6 4 6 2"
    "2 6 5 7 2"
    "1 7 5 7 1"
    "1 6 6 6 1"
    "2 5 6 5 2"
    "2 4 7 4 2"
    "3 3 7 3 3"
    "3 4 6 4 3"
    "2 5 5 5 2"
    "1 4 5 4 1"
)
FRAME_COUNT=${#FRAMES[@]}

# ── Helper: build visualizer string from a frame ──────────────────────────────
build_viz() {
    local viz=""
    read -ra heights <<< "$1"
    for h in "${heights[@]}"; do
        viz+="${BAR_CHARS[$h]}"
    done
    echo "$viz"
}

FROZEN_VIZ="▂▂▂▂▂"

# ── State (in-memory, no file I/O per tick) ───────────────────────────────────
POS=0
FRAME=0
LAST_TITLE=""

# ── Main loop ─────────────────────────────────────────────────────────────────
while true; do
    STATUS=$(playerctl status 2>/dev/null)

    # No player
    if [ -z "$STATUS" ] || [ "$STATUS" = "No players found" ]; then
        printf '{"text": "▂▂▂▂▂  󰓛  no music playing", "class": "stopped", "tooltip": "No media player active"}\n'
        sleep "$SLEEP_INTERVAL"
        continue
    fi

    ARTIST=$(playerctl metadata artist 2>/dev/null)
    TITLE=$(playerctl metadata title  2>/dev/null)

    if [ -z "$TITLE" ]; then
        printf '{"text": "▂▂▂▂▂  󰓛  no music playing", "class": "stopped", "tooltip": "No track loaded"}\n'
        sleep "$SLEEP_INTERVAL"
        continue
    fi

    # Reset scroll position when track changes
    if [ "$TITLE" != "$LAST_TITLE" ]; then
        POS=0
        LAST_TITLE="$TITLE"
    fi

    if [ -n "$ARTIST" ]; then
        FULL_TEXT="$ARTIST — $TITLE"
    else
        FULL_TEXT="$TITLE"
    fi

    # Icon + visualizer
    case "$STATUS" in
        "Playing")
            ICON="󰎆"
            VIZ=$(build_viz "${FRAMES[$FRAME]}")
            FRAME=$(( (FRAME + 1) % FRAME_COUNT ))
            ;;
        "Paused")
            ICON="󰏤"
            VIZ="$FROZEN_VIZ"
            ;;
        "Stopped")
            ICON="󰓛"
            VIZ="$FROZEN_VIZ"
            FRAME=0
            ;;
        *)
            ICON="󰎆"
            VIZ=$(build_viz "${FRAMES[$FRAME]}")
            FRAME=$(( (FRAME + 1) % FRAME_COUNT ))
            ;;
    esac

    CLASS="$(echo "$STATUS" | tr '[:upper:]' '[:lower:]')"
    PREFIX="${VIZ}  ${ICON}  "

    # Scrolling text
    TEXT_LEN=${#FULL_TEXT}
    if [ "$TEXT_LEN" -le "$MAX_WIDTH" ]; then
        POS=0
        DISPLAY_TEXT="${PREFIX}${FULL_TEXT}"
    else
        PADDING="    ·    "
        SCROLL_TEXT="${FULL_TEXT}${PADDING}"
        SCROLL_LEN=${#SCROLL_TEXT}

        VISIBLE=""
        for i in $(seq 0 $((MAX_WIDTH - 1))); do
            IDX=$(( (POS + i) % SCROLL_LEN ))
            VISIBLE="${VISIBLE}${SCROLL_TEXT:$IDX:1}"
        done

        POS=$(( (POS + SCROLL_SPEED) % SCROLL_LEN ))
        DISPLAY_TEXT="${PREFIX}${VISIBLE}"
    fi

    TOOLTIP="${FULL_TEXT}\nStatus: ${STATUS}"
    printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' \
        "$DISPLAY_TEXT" "$CLASS" "$TOOLTIP"

    sleep "$SLEEP_INTERVAL"
done

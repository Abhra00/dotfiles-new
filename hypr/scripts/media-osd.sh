#!/usr/bin/env bash
# ┳┳┓┏┓┳┓┳┏┓  ┏┓┏┓┳┓
# ┃┃┃┣ ┃┃┃┣┫━━┃┃┗┓┃┃
# ┛ ┗┗┛┻┛┻┛┗  ┗┛┗┛┻┛
#

iDIR="$HOME/.config/mako/assets"
THUMB="/tmp/media-osd-thumb.png"
THUMB_RAW="/tmp/media-osd-raw.png"
BADGE_TMP="/tmp/media-osd-badge.png"
COMPOSITED="/tmp/media-osd-composited.png"
LOCK="/tmp/media-osd.lock"
ART_URL_CACHE="/tmp/media-osd-url.cache"

BG="#141210"

ART_SIZE=96
BADGE_SIZE=36
ICON_SIZE=20

# ── debounce ──────────────────────────────────────────────────────────────────
# On rapid skipping each new invocation kills the previous one still sleeping/
# processing. Only the last press in a burst actually does the heavy work.
debounce() {
    if [ -f "$LOCK" ]; then
        local old_pid
        old_pid=$(cat "$LOCK" 2>/dev/null)
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            kill -- -"$old_pid" 2>/dev/null   # kill process group
            kill "$old_pid"     2>/dev/null
        fi
    fi
    echo $$ > "$LOCK"
}

# ── helpers ───────────────────────────────────────────────────────────────────

truncate_title() {
    local input="$1"
    local max=40
    [ -z "$input" ] && echo "Unknown" && return
    input="$(printf '%s' "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ "${#input}" -gt "$max" ]; then
        printf '%s...\n' "${input:0:$((max-3))}"
    else
        printf '%s\n' "$input"
    fi
}

wait_for_track_change() {
    local old_title="$1"
    local new_title
    local attempts=0
    local max=30   # ~3 seconds
    while [ $attempts -lt $max ]; do
        new_title=$(playerctl metadata title 2>/dev/null)
        if [ "$new_title" != "$old_title" ] && [ -n "$new_title" ]; then
            return 0
        fi
        sleep 0.1
        attempts=$((attempts + 1))
    done
}

# ── badge ─────────────────────────────────────────────────────────────────────
make_badge() {
    local badge_icon="$1"
    local half=$((BADGE_SIZE / 2))
    local offset=$(( (BADGE_SIZE - ICON_SIZE) / 2 ))

    magick \
        -size ${BADGE_SIZE}x${BADGE_SIZE} xc:none \
        -fill "$BG" \
        -draw "circle ${half},${half} ${half},1" \
        \( "$badge_icon" -resize ${ICON_SIZE}x${ICON_SIZE} \) \
        -geometry +${offset}+${offset} \
        -composite \
        "$BADGE_TMP" 2>/dev/null
}

# ── art + badge composite ──────────────────────────────────────────────────────
get_art() {
    local url status badge_icon
    url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    status=$(playerctl status 2>/dev/null)

    case "$status" in
        Playing) badge_icon="$iDIR/media-play.png"  ;;
        *)       badge_icon="$iDIR/media-pause.png" ;;
    esac

    make_badge "$badge_icon"

    # ── art URL cache: skip ffmpeg+magick if same track art as last time ──────
    local cached_url
    cached_url=$(cat "$ART_URL_CACHE" 2>/dev/null)
    if [ "$url" = "$cached_url" ] && [ -s "$THUMB_RAW" ]; then
        # Art unchanged — just re-composite badge on existing raw art
        local inset=4
        magick "$THUMB_RAW" \
            \( "$BADGE_TMP" \) \
            -gravity SouthEast \
            -geometry +${inset}+${inset} \
            -composite \
            "$THUMB" 2>/dev/null
        return
    fi

    # New art — fetch and decode
    local art_ok=0

    if [[ "$url" == file://* ]]; then
        ffmpeg -y -i "${url#file://}" \
            -vf "scale=${ART_SIZE}:${ART_SIZE}:force_original_aspect_ratio=increase,crop=${ART_SIZE}:${ART_SIZE}" \
            "$THUMB_RAW" -loglevel quiet 2>/dev/null && art_ok=1

    elif [[ "$url" == http* ]]; then
        curl -sL --max-time 3 "$url" -o "/tmp/media-osd-dl" 2>/dev/null && \
        ffmpeg -y -i "/tmp/media-osd-dl" \
            -vf "scale=${ART_SIZE}:${ART_SIZE}:force_original_aspect_ratio=increase,crop=${ART_SIZE}:${ART_SIZE}" \
            "$THUMB_RAW" -loglevel quiet 2>/dev/null && art_ok=1
    fi

    if [ "$art_ok" -eq 1 ] && [ -s "$THUMB_RAW" ] && [ -f "$BADGE_TMP" ]; then
        printf '%s' "$url" > "$ART_URL_CACHE"
        local inset=4
        magick "$THUMB_RAW" \
            \( "$BADGE_TMP" \) \
            -gravity SouthEast \
            -geometry +${inset}+${inset} \
            -composite \
            "$COMPOSITED" 2>/dev/null && \
        cp "$COMPOSITED" "$THUMB"
    else
        magick \
            -size ${ART_SIZE}x${ART_SIZE} "xc:${BG}" \
            \( "$BADGE_TMP" \) \
            -gravity Center \
            -composite \
            "$THUMB" 2>/dev/null || \
        cp "$BADGE_TMP" "$THUMB"
    fi
}

# ── notification ───────────────────────────────────────────────────────────────

send_notif_with_art() {
    local raw_title title icon
    raw_title=$(playerctl metadata title 2>/dev/null)
    title=$(truncate_title "$raw_title")
    get_art
    [ -s "$THUMB" ] && icon="$THUMB" || icon="$iDIR/media-pause.png"

    notify-send \
        -a "MediaOSD" \
        -i "$icon" \
        -h "string:x-canonical-private-synchronous:media-osd" \
        -t 3000 \
        "$title" ""
}

# ── dispatch ───────────────────────────────────────────────────────────────────

case "$1" in
    play|pause)
        debounce
        playerctl play-pause
        sleep 0.1
        send_notif_with_art
        ;;
    next)
        debounce
        local_title=$(playerctl metadata title 2>/dev/null)
        playerctl next
        wait_for_track_change "$local_title"
        sleep 0.15
        send_notif_with_art
        ;;
    prev)
        debounce
        local_title=$(playerctl metadata title 2>/dev/null)
        playerctl previous
        wait_for_track_change "$local_title"
        sleep 0.15
        send_notif_with_art
        ;;
    info)
        send_notif_with_art
        ;;
esac

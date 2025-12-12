#!/usr/bin/env bash
#    ┳┓┏┓┏┓┳  ┓┏┓┏┓┓┏┳┓┳┳┓┳┓  ┏┓┓┏┏┓┏┓┏┳┓┏┓┓┏┏┓┏┓┏┳┓
#    ┣┫┃┃┣ ┃━━┃┫ ┣ ┗┫┣┫┃┃┃┃┃━━┃ ┣┫┣ ┣┫ ┃ ┗┓┣┫┣ ┣  ┃
#    ┛┗┗┛┻ ┻  ┛┗┛┗┛┗┛┻┛┻┛┗┻┛  ┗┛┛┗┗┛┛┗ ┻ ┗┛┛┗┗┛┗┛ ┻
#

# A script to display Hyprland keybindings defined in your configuration
# Requirements: hyprctl, jq, xkbcli, awk, sort, cut, and a dmenu-compatible tool (e.g., rofi)

declare -A KEYCODE_SYM_MAP

# --- Keymap Building ---

# Builds a cache mapping numeric keycodes to their symbolic names (e.g., 65 -> Super_L)
build_keymap_cache() {
    local keymap
    keymap="$(xkbcli compile-keymap)" || {
        echo "Failed to compile keymap. Please ensure xkbcli is installed." >&2
        return 1
    }

    # Use awk to parse the xkbcli output and generate a 'code,symbol' list
    while IFS=, read -r code sym; do
        [[ -z "$code" || -z "$sym" ]] && continue
        KEYCODE_SYM_MAP["$code"]="$sym"
    done < <(
        echo "$keymap" | awk '
            BEGIN { sec = "" }
            /xkb_keycodes/ { sec = "codes"; next }
            /xkb_symbols/  { sec = "syms";  next }
            sec == "codes" && match($0, /<([A-Za-z0-9_]+)>\s*=\s*([0-9]+)\s*;/, m) {
                code_by_name[m[1]] = m[2]
            }
            sec == "syms" && match($0, /key\s*<([A-Za-z0-9_]+)>\s*\{\s*\[\s*([^, \]]+)/, m) {
                sym_by_name[m[1]] = m[2]
            }
            END {
                # Map codes to symbols for the final output
                for (k in code_by_name) {
                    c = code_by_name[k]
                    s = sym_by_name[k]
                    if (c != "" && s != "" && s != "NoSymbol") print c "," s
                }
            }
        '
    )
}

lookup_keycode_cached() {
    printf '%s\n' "${KEYCODE_SYM_MAP[$1]}"
}

# --- Parsing and Formatting ---

# Translates numeric keycodes (from hyprctl) and mouse button codes to symbolic names.
parse_keycodes() {
    while IFS= read -r line; do
        if [[ "$line" =~ code:([0-9]+) ]]; then
            # Keycode translation
            code="${BASH_REMATCH[1]}"
            symbol=$(lookup_keycode_cached "$code")
            echo "${line/code:${code}/$symbol}"
        elif [[ "$line" =~ mouse:([0-9]+) ]]; then
            # Mouse button translation
            code="${BASH_REMATCH[1]}"

            case "$code" in
                272) symbol="LEFT MOUSE BUTTON" ;;
                273) symbol="RIGHT MOUSE BUTTON" ;;
                274) symbol="MIDDLE MOUSE BUTTON" ;;
                *)   symbol="mouse:${code}" ;;
            esac

            echo "${line/mouse:${code}/$symbol}"
        else
            echo "$line"
        fi
    done
}

# Fetches dynamic keybindings from Hyprland and pre-processes them.
dynamic_bindings() {
    hyprctl -j binds |
        jq -r '
            .[] |
            select(
                .arg |
                tostring |
                (
                    contains("swayosd-client") and
                    (contains("--caps-lock") or contains("--num-lock"))
                ) |
                not
            ) |
            {modmask, key, keycode, description, dispatcher, arg} |
            "\(.modmask),\(.key)@\(.keycode),\(.description),\(.dispatcher),\(.arg)"
        ' |
        sed -r \
            -e 's/null//g' \
            -e 's/@0//' \
            -e 's/,@/,code:/' \
            -e 's/^0,/,/' \
            -e 's/^1,/SHIFT,/' \
            -e 's/^4,/CTRL,/' \
            -e 's/^5,/SHIFT CTRL,/' \
            -e 's/^8,/ALT,/' \
            -e 's/^9,/SHIFT ALT,/' \
            -e 's/^12,/CTRL ALT,/' \
            -e 's/^13,/SHIFT CTRL ALT,/' \
            -e 's/^64,/SUPER,/' \
            -e 's/^65,/SUPER SHIFT,/' \
            -e 's/^68,/SUPER CTRL,/' \
            -e 's/^69,/SUPER SHIFT CTRL,/' \
            -e 's/^72,/SUPER ALT,/' \
            -e 's/^73,/SUPER SHIFT ALT,/' \
            -e 's/^76,/SUPER CTRL ALT,/' \
            -e 's/^77,/SUPER SHIFT CTRL ALT,/'
}

# Final formatting for the menu display.
parse_bindings() {
    awk -F, '
{
    # $1: Modifiers
    # $2: Key/Code
    # $3: Description (or empty)
    # $4: Dispatcher
    # $5..NF: Arguments

    # 1. Build the Key Combination string (e.g., SUPER + CTRL + R)
    key_combo = $1 " + " $2;
    gsub(/^[ \t]*\+?[ \t]*/, "", key_combo); # Clean up leading "+"
    gsub(/[ \t]+/, " ", key_combo);          # Collapse multiple spaces

    # 2. Determine the Action string
    action = $3; # Start with the description field

    if (action == "") {
        # If no description, reconstruct the command from dispatcher/args
        action = $4;
        for (i = 5; i <= NF; i++) {
            action = action " " $i;
        }
        # Clean up leading "exec " (case-insensitive for Hyprland)
        if (match(action, /^[[:space:]]*(exec[[:space:]]+)/, m)) {
            action = substr(action, length(m[1]) + 1);
        }
        gsub(/^[ \t]+|[ \t]+$/, "", action); # Trim spaces
    }

    if (action != "") {
        # Format: Key Combination (left aligned) → Action (right aligned)
        printf "%-35s → %s\n", key_combo, action;
    }
}'
}

# Prioritizes entries for better sorting in the menu.
prioritize_entries() {
    awk '
    {
        line = $0
        prio = 50 # Default/General priority
        # Lower numbers = higher priority (appear first)
        if (match(line, /Terminal/)) prio = 0
        if (match(line, /Browser/) && !match(line, /Browser[[:space:]]*\(/)) prio = 1
        if (match(line, /File manager/))  prio = 2
        if (match(line, /Close window/))  prio = 8
        if (match(line, /Toggle window floating/))  prio = 9
        if (match(line, /Screenshot/))  prio = 15
        if (match(line, /(Switch|Next|Former|Previous).*workspace/))  prio = 17
        if (match(line, /Move window to workspace/))  prio = 18
        if (match(line, /Move window focus/))  prio = 20
        if (match(line, /Scroll active workspace/))  prio = 95
        if (match(line, /XF86/))  prio = 99 # Media/Special keys last
        # Print "priority<TAB>line"
        printf "%d\t%s\n", prio, line
    }' |
    sort -k1,1n -k2,2 | # Sort by priority (numeric) then by line content (alphabetical)
    cut -f2- # Remove the priority field
}

# --- Execution ---
build_keymap_cache

dynamic_bindings |
    sort -u |
    parse_keycodes |
    parse_bindings |
    prioritize_entries |
    rofi -dmenu -p 'Keybindings' -theme ~/.config/rofi/hyprCheatSheet.rasi

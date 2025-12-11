#!/usr/bin/env bash
#┏┓┏┓┏┓┳┳┓┏┓┳┓  ┳┳┏┓┳┓┏┓┏┳┓┏┓
#┃┃┣┫┃ ┃┃┃┣┫┃┃━━┃┃┃┃┃┃┣┫ ┃ ┣
#┣┛┛┗┗┛┛ ┗┛┗┛┗  ┗┛┣┛┻┛┛┗ ┻ ┗┛
#

# Get pacman updates
pacman_updates=$(checkupdates 2>/dev/null | wc -l)

# Get AUR updates using yay or paru
if command -v yay &>/dev/null; then
    aur_updates=$(yay -Qum 2>/dev/null | wc -l)
elif command -v paru &>/dev/null; then
    aur_updates=$(paru -Qum 2>/dev/null | wc -l)
else
    aur_updates=0
fi

# Total
total_updates=$((pacman_updates + aur_updates))

# Values
TEXT="󰏔 $total_updates"
TOOLTIP="Pacman: $pacman_updates\nAUR: $aur_updates\nTotal: $total_updates"

# Escape newlines for JSON
TOOLTIP_ESCAPED=$(echo -e "$TOOLTIP" | sed ':a;N;$!ba;s/\n/\\n/g')

# Output JSON
echo "{\"text\":\"$TEXT\", \"tooltip\":\"$TOOLTIP_ESCAPED\", \"class\":\"updates\"}"

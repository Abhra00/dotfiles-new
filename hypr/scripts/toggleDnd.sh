#!/usr/bin/env bash
# ┏┳┓┏┓┏┓┏┓┓ ┏┓  ┳┓┳┓┳┓  
#  ┃ ┃┃┃┓┃┓┃ ┣ ━━┃┃┃┃┃┃  
#  ┻ ┗┛┗┛┗┛┗┛┗┛  ┻┛┛┗┻┛
#

iDIR="$HOME/.config/mako/assets"

if makoctl mode | grep -q "do-not-disturb"; then
    notify-send -a "DndOSD" "Do Not Disturb" "Disabled" \
        -i "$iDIR/dnd-off.svg" \
        -e -h "int:transient:1"
    makoctl mode -t do-not-disturb
else
    notify-send -a "DndOSD" "Do Not Disturb" "Enabled" \
        -i "$iDIR/dnd-on.svg" \
        -e -h "int:transient:1"
    sleep 2
    makoctl mode -t do-not-disturb
fi

#!/usr/bin/env bash
#  ┳┓┏┓┏┓┳┓┏┓┏┓┓┏
#  ┣┫┣ ┣ ┣┫┣ ┗┓┣┫
#  ┛┗┗┛┻ ┛┗┗┛┗┛┛┗
#

#!/usr/bin/env bash
#  ┳┓┏┓┏┓┳┓┏┓┏┓┓┏
#  ┣┫┣ ┣ ┣┫┣ ┗┓┣┫
#  ┛┗┗┛┻ ┛┗┗┛┗┛┛┗
#

# kill already running processes
_ps=(waybar swaync swayosd-server rofi)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# relaunch waybar
sleep 1
setsid -f waybar

# relaunch swaync
sleep 0.5
setsid -f swaync >/dev/null 2>&1 &

# relaunch swayosd-server
sleep 0.5
setsid -f swayosd-server >/dev/null 2>&1 &

# send notification
notify-send \
    -e -h \
    string:x-canonical-private-synchronous:refreshing \
    -i "$HOME/.config/swaync/assets/bell.png" \
    "✨ Refresh ✨" \
    "WAYBAR\nROFI\nSWAYOSD\nSWAYNC\n✨restarted ✨"
exit 0

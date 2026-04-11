#!/usr/bin/env bash
#  ┳┓┏┓┏┓┳┓┏┓┏┓┓┏
#  ┣┫┣ ┣ ┣┫┣ ┗┓┣┫
#  ┛┗┗┛┻ ┛┗┗┛┗┛┛┗
#

# kill already running processes
_ps=(waybar rofi)
for _prs in "${_ps[@]}"; do
  if pidof "${_prs}" >/dev/null; then
    pkill "${_prs}"
  fi
done

# relaunch waybar
sleep 1
setsid -f hyprctl dispatch exec waybar

# reload mako
sleep 0.5
makoctl reload

# send notification
notify-send \
  -e -h \
  string:x-canonical-private-synchronous:refreshing \
  -i "$HOME/.config/mako/assets/refresh.svg" \
  "✨ REFRESH ✨" \
  "✨ WAYBAR ✨\n✨ ROFI ✨\n✨ MAKO ✨\n✨ RESTARTED ✨"
exit 0

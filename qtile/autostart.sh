#!/usr/bin/env bash
#    ┏┓┳┳┏┳┓┏┓┏┓┏┳┓┏┓┳┓┏┳┓
#    ┣┫┃┃ ┃ ┃┃┗┓ ┃ ┣┫┣┫ ┃
#    ┛┗┗┛ ┻ ┗┛┗┛ ┻ ┛┗┛┗ ┻
#

# DPI (optional; Qtile can also set DPI in config)
xrandr --dpi 96

# Keyboard rate
sleep 1
xset r rate 200 55

# Xresources colors/settings on startup
xrdb ${XDG_CONFIG_HOME:-$HOME/.config}/x11/xresources &
xrdbpid=$!

# Modifier tuning
xmodmap -e "clear control" -e "add control = Control_L" \
  -e "clear mod3" -e "add mod3 = Control_R"

xmodmap -e "clear mod1" -e "add mod1 = Alt_L" \
  -e "clear mod5" -e "add mod5 = Alt_R" &

# Apps to autostart once
apps=(
  "dunst"
  "picom"
  "blueman-applet"
  "unclutter"
)

for app in "${apps[@]}"; do
  pgrep -x "$app" >/dev/null || "$app" &
done

# Polkit agent
if [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
  pgrep -f polkit-gnome-authentication-agent-1 >/dev/null ||
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# Copyq daemon
pgrep -x copyq >/dev/null || copyq --start-server &

# Ensure that xrdb has finished running before moving on to start the WM/DE
[ -n "$xrdbpid" ] && wait "$xrdbpid"

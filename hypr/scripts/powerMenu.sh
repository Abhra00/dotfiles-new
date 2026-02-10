#!/usr/bin/env bash
#  ┏┓┏┓┓ ┏┏┓┳┓┳┳┓┏┓┳┓┳┳
#  ┃┃┃┃┃┃┃┣ ┣┫┃┃┃┣ ┃┃┃┃
#  ┣┛┗┛┗┻┛┗┛┛┗┛ ┗┗┛┛┗┗┛
#

# Current Theme
theme='powermenu.rasi'

# Message
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
shutdown=$(printf '\uf418')
reboot=$(printf '\ue8ba')
lock=$(printf '\uf8f3')
suspend=$(printf '\uf34f')
logout=$(printf '\uf1ff')
yes=$(printf '\uef76')
no=$(printf '\ueffb')

# Rofi CMD
rofi_cmd() {
  rofi -dmenu -p "Uptime: $uptime" -mesg "Uptime: $uptime" -theme "$theme"
}

# Confirmation CMD
confirm_cmd() {
  rofi -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme confirm.rasi
}

# Ask for confirmation
confirm_exit() {
  printf "%s\n%s" "$yes" "$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
  printf "%s\n%s\n%s\n%s\n%s" \
    "$lock" "$suspend" "$logout" "$reboot" "$shutdown" | rofi_cmd
}

# Execute selected power action
run_cmd() {
  selected="$(confirm_exit)"

  if [[ "$selected" == "$yes" ]]; then
    case "$1" in
    --lock) loginctl lock-session ;;
    --shutdown)
      hyprctl clients -j | jq -r '.[].pid' | xargs kill
      systemctl poweroff
      ;;
    --reboot)
      hyprctl clients -j | jq -r '.[].pid' | xargs kill
      systemctl reboot
      ;;
    --suspend) systemctl suspend ;;
    --logout)
      hyprctl clients -j | jq -r '.[].pid' | xargs kill
      pkill Hyprland
      ;;
    esac
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case "$chosen" in
$shutdown) run_cmd --shutdown ;;
$reboot) run_cmd --reboot ;;
$lock) run_cmd --lock ;;
$suspend) run_cmd --suspend ;;
$logout) run_cmd --logout ;;
esac

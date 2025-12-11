#!/usr/bin/env bash
#  ┏┓┏┓┓ ┏┏┓┳┓┳┳┓┏┓┳┓┳┳
#  ┃┃┃┃┃┃┃┣ ┣┫┃┃┃┣ ┃┃┃┃
#  ┣┛┗┛┗┻┛┗┛┛┗┛ ┗┗┛┛┗┗┛
#

# Current Theme
theme='powermenu.rasi'

# Options
shutdown='󰐥'
reboot='󰜉'
lock='󰌾'
suspend='󰤄'
logout='󰈆'
yes=''
no=''

# Rofi CMD
rofi_cmd() {
  rofi -dmenu -theme "$theme"
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
      --shutdown) systemctl poweroff ;;
      --reboot)   systemctl reboot ;;
      --suspend)  systemctl suspend ;;
      --logout)   hyprctl dispatch exit ;;
    esac
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case "$chosen" in
  $shutdown) run_cmd --shutdown ;;
  $reboot)   run_cmd --reboot ;;
  $lock)     loginctl lock-session ;;
  $suspend)  run_cmd --suspend ;;
  $logout)   run_cmd --logout ;;
esac

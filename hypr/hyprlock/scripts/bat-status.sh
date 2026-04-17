#!/usr/bin/env bash
# ┳┓┏┓┏┳┓  ┏┓┏┳┓┏┓┏┳┓┳┳┏┓
# ┣┫┣┫ ┃ ━━┗┓ ┃ ┣┫ ┃ ┃┃┗┓
# ┻┛┛┗ ┻   ┗┛ ┻ ┛┗ ┻ ┗┛┗┛
#

enable_battery=false
is_discharging=false

for battery in /sys/class/power_supply/*BAT*; do
  if [[ -f "$battery/uevent" ]]; then
    enable_battery=true

    status=$(<"$battery/status")
    capacity=$(<"$battery/capacity")

    if [[ "$status" == "Discharging" ]]; then
      is_discharging=true
    fi

    break
  fi
done

if [[ $enable_battery == true ]]; then
  # Battery icon selection
  if (( capacity <= 5 )); then
    icon_name="battery_android_0"
  elif (( capacity <= 15 )); then
    icon_name="battery_android_1"
  elif (( capacity <= 30 )); then
    icon_name="battery_android_2"
  elif (( capacity <= 45 )); then
    icon_name="battery_android_3"
  elif (( capacity <= 60 )); then
    icon_name="battery_android_4"
  elif (( capacity <= 75 )); then
    icon_name="battery_android_5"
  elif (( capacity <= 90 )); then
    icon_name="battery_android_6"
  else
    icon_name="battery_android_full"
  fi

  # Icon rendering
  if [[ $is_discharging == true ]]; then
    icon="<span font_family='Material Symbols Rounded' size='16pt' rise='-4500'>$icon_name</span>"
  else
    icon="<span font_family='Material Symbols Rounded' size='16pt' rise='-4500'>battery_android_frame_bolt</span>"
  fi

  # Low battery warning
  if (( capacity <= 20 )) && [[ $is_discharging == true ]]; then
    echo "<span foreground='#c06c5c'>$icon $capacity%</span>"
  else
    echo "$icon $capacity%"
  fi
fi

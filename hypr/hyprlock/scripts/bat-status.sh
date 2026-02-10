#!/usr/bin/env bash
############ Variables ############
enable_battery=false
battery_charging=false
####### Check availability ########
for battery in /sys/class/power_supply/*BAT*; do
  if [[ -f "$battery/uevent" ]]; then
    enable_battery=true
    if [[ $(cat /sys/class/power_supply/*/status | head -1) == "Charging" ]]; then
      battery_charging=true
    fi
    break
  fi
done
############# Output #############
if [[ $enable_battery == true ]]; then
  capacity=$(cat /sys/class/power_supply/*/capacity | head -1)
  # Determine battery icon based on level (battery_0_bar to battery_full)
  if [[ $capacity -le 5 ]]; then
    icon_name="battery_android_0"
  elif [[ $capacity -le 15 ]]; then
    icon_name="battery_android_1"
  elif [[ $capacity -le 30 ]]; then
    icon_name="battery_android_2"
  elif [[ $capacity -le 45 ]]; then
    icon_name="battery_android_3"
  elif [[ $capacity -le 60 ]]; then
    icon_name="battery_android_4"
  elif [[ $capacity -le 75 ]]; then
    icon_name="battery_android_5"
  elif [[ $capacity -le 90 ]]; then
    icon_name="battery_android_6"
  else
    icon_name="battery_android_full"
  fi
  # Add charging indicator if charging
  if [[ $battery_charging == true ]]; then
    icon="<span font_family='Material Symbols Rounded' size='16pt' rise='-3500'>battery_android_frame_bolt</span>"
  else
    icon="<span font_family='Material Symbols Rounded' size='16pt' rise='-3500'>$icon_name</span>"
  fi
  # Add color for low battery
  if [[ $capacity -le 20 && $battery_charging == false ]]; then
    echo "<span foreground='#ff5555'>$icon $capacity%</span>"
  else
    echo "$icon $capacity%"
  fi
fi

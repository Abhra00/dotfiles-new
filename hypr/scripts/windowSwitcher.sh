#!/usr/bin/env bash

# Get the open window counts
WINDOW_COUNT=$(hyprctl clients -j | jq length)

# Rofi theme file
ROFI_THEME="$HOME/.config/rofi/windowSwitcher.rasi"

# Calculate the window width
WINDOW_WIDTH=$((WINDOW_COUNT * 150))

# Run rofi
pkill rofi || rofi -show window -theme-str "window { width: ${WINDOW_WIDTH}px; } listview { columns: $WINDOW_COUNT; }" -theme "$ROFI_THEME"

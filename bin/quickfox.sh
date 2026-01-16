#!/usr/bin/env bash

#!/usr/bin/env bash

# Usage: ./quickfox.sh <fg_hex> <bg_hex>
# Example: ./quickfox.sh "#ffcc00" "#1e1e2e"

FG_HEX="$1"
BG_HEX="$2"

TEXT="The quick brown fox jumps over the lazy dog"

# Validate input
if [[ -z "$FG_HEX" || -z "$BG_HEX" ]]; then
  echo "Usage: $0 <fg_hex> <bg_hex>"
  echo 'Example: $0 "#ffcc00" "#1e1e2e"'
  exit 1
fi

hex_to_rgb() {
  local hex="${1#\#}"
  printf "%d;%d;%d" \
    "0x${hex:0:2}" \
    "0x${hex:2:2}" \
    "0x${hex:4:2}"
}

FG_RGB=$(hex_to_rgb "$FG_HEX")
BG_RGB=$(hex_to_rgb "$BG_HEX")

# 38;2;r;g;b → foreground (truecolor)
# 48;2;r;g;b → background (truecolor)
echo -e "\e[38;2;${FG_RGB};48;2;${BG_RGB}m${TEXT}\e[0m"

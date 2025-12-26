#/usr/bin/env bash
# ┳┓┓┏┳┓┏┓┳┳┓┳┏┓  ┏┓┏┓┏┓┏┓┳┏┳┓┓┏  ┏┓┓┏┏┓┳┓┏┓┏┓┳┓
# ┃┃┗┫┃┃┣┫┃┃┃┃┃ ━━┃┃┃┃┣┫┃ ┃ ┃ ┗┫━━┃ ┣┫┣┫┃┃┃┓┣ ┣┫
# ┻┛┗┛┛┗┛┗┛ ┗┻┗┛  ┗┛┣┛┛┗┗┛┻ ┻ ┗┛  ┗┛┛┗┛┗┛┗┗┛┗┛┛┗
#

# Opacity changing step and max opacity and min opacity
STEP=0.01
MIN=0.5
MAX=1.0

ACTION=$1

# Get current alpha (dynamic multiplier)
CURR_ALPHA=$(hyprctl getprop active alpha)


case "$ACTION" in
  up)
    NEW_ALPHA=$(echo "$CURR_ALPHA + $STEP" | bc -l)
    NEW_ALPHA=$(echo "if ($NEW_ALPHA > $MAX) $MAX else $NEW_ALPHA" | bc -l)
    hyprctl dispatch setprop active alpha $NEW_ALPHA
    ;;
  down)
    NEW_ALPHA=$(echo "$CURR_ALPHA - $STEP" | bc -l)
    NEW_ALPHA=$(echo "if ($NEW_ALPHA < $MIN) $MIN else $NEW_ALPHA" | bc -l)
    hyprctl dispatch setprop active alpha $NEW_ALPHA
    ;;
  toggle)
    hyprctl dispatch setprop active opaque toggle
    ;;
  *)
    echo "Usage: $0 up|down|*"
    exit 1
    ;;
esac

# Apply new alpha

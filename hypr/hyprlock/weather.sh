#!/bin/bash

#!/bin/bash

# Path to weather cache
WEATHER_CACHE="$HOME/.cache/.weather_cache"

# Check if cache exists
[[ ! -f "$WEATHER_CACHE" ]] && echo "No weather data" && exit 1

# Parse weather data
condition=$(awk 'NR==1 {printf "%s %s\n", $1, $2}' "$WEATHER_CACHE")
feels_like=$(awk 'NR==2 {match($0, /Feels like [0-9]+/); temp=substr($0, RSTART, RLENGTH); gsub(/Feels like /, "", temp); print temp}' "$WEATHER_CACHE")

# Output
if [[ -n "$feels_like" && -n "$condition" ]]; then
    echo "Feels like ${feels_like}° | ${condition}"
else
    echo "Weather unavailable"
fi

#!/usr/bin/env python3
#  ┓ ┏┏┓┏┓┏┳┓┓┏┏┓┳┓
#  ┃┃┃┣ ┣┫ ┃ ┣┫┣ ┣┫
#  ┗┻┛┗┛┛┗ ┻ ┛┗┗┛┛┗
#
# Weather for Waybar
# Original: JaKooLit / Surendrajat
# Modified: No #regionHeader dependency, uses status text → Nerd Font icon mapping

import requests
import json
import os
from pyquery import PyQuery  # install: pip install pyquery

# Weather status → Nerd Font icon mapping
status_icons = {
    "sunny": "󰖙",
    "clear": "󰖔",
    "mostly sunny": "",
    "partly cloudy": "",
    "mostly cloudy": "",
    "cloudy": "",
    "overcast": "",
    "fog": "",
    "haze": "",
    "rain": "",
    "showers": "",
    "light rain": "",
    "thunderstorm": "",
    "snow": "",
    "sleet": "",
    "windy": "",
    "default": "",
}

# Get location from IP
def get_location():
    response = requests.get("https://ipinfo.io", timeout=5)
    data = response.json()
    loc = data["loc"].split(",")
    return float(loc[0]), float(loc[1])

latitude, longitude = get_location()

# Get weather.com HTML
url = f"https://weather.com/en-PH/weather/today/l/{latitude},{longitude}"
html_data = PyQuery(url=url)

# Current temperature
temp = html_data("span[data-testid='TemperatureValue']").eq(0).text()

# Status text & icon
status = html_data("div[data-testid='wxPhrase']").text().strip()
status_lower = status.lower()
icon = status_icons.get(status_lower, status_icons["default"])

# Feels-like temperature
temp_feel = html_data(
    "div[data-testid='FeelsLikeSection'] span[data-testid='TemperatureValue']"
).text()
temp_feel_text = f"Feels like {temp_feel}c"

# Min / Max temperature
temp_min = html_data("div[data-testid='wxData'] span[data-testid='TemperatureValue']").eq(1).text()
temp_max = html_data("div[data-testid='wxData'] span[data-testid='TemperatureValue']").eq(0).text()
temp_min_max = f"    {temp_min}\t\t   {temp_max}"

# Wind speed
wind_speed = html_data("span[data-testid='Wind'] span").text()
wind_text = f" {wind_speed}"

# Humidity
humidity = html_data("span[data-testid='PercentageValue']").text()
humidity_text = f"           {humidity}"

# Visibility
visibility = html_data("span[data-testid='VisibilityValue']").text()
visibility_text = f"󰮔   {visibility}"

# Air quality
air_quality_index = html_data("text[data-testid='DonutChartValue']").text()

# Hourly rain prediction
prediction = html_data("section[aria-label='Hourly Forecast'] div[data-testid='SegmentPrecipPercentage'] span").text()
prediction = prediction.replace("Chance of Rain", "")
prediction = f"\n\n (hourly) {prediction}" if prediction else ""

# Tooltip text for Waybar
tooltip_text = str.format(
    "\t\t{}\t\t\n{}\n{}\n{}\n\n{}\n{}\n{}{}",
    f'<span size="xx-large">{temp}</span>',
    f"<big> {icon}</big>",
    f"<b>{status}</b>",
    f"<small>{temp_feel_text}</small>",
    f"<b>{temp_min_max}</b>",
    f"{wind_text}\t{humidity_text}",
    f"{visibility_text}\t        AQI {air_quality_index}",
    f"<i> {prediction}</i>",
)

# JSON output for Waybar
out_data = {
    "text": f"{icon} {temp}",
    "alt": status,
    "tooltip": tooltip_text,
    "class": status_lower.replace(" ", "-"),
}
print(json.dumps(out_data))

# Simple text weather for cache file
simple_weather = (
    f"{icon} {status}\n"
    + f" {temp} ({temp_feel_text})\n"
    + f"{wind_text}\n"
    + f"{humidity_text}\n"
    + f"{visibility_text} AQI {air_quality_index}\n"
)

try:
    with open(os.path.expanduser("~/.cache/.weather_cache"), "w") as file:
        file.write(simple_weather)
except Exception as e:
    print(f"Error writing to cache: {e}")


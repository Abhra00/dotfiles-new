#!/usr/bin/env bash

# Function to get metadata using playerctl
get_metadata() {
	key=$1
	playerctl metadata --format "{{ $key }}" 2>/dev/null
}

# Function to determine the source and return an icon and text
get_source_info() {
	trackid=$(get_metadata "mpris:trackid")
	if [[ "$trackid" == *"firefox"* ]]; then
		echo -e "󰈹 Firefox"
	elif [[ "$trackid" == *"spotify"* ]]; then
		echo -e " Spotify"
	elif [[ "$trackid" == *"chromium"* ]]; then
		echo -e " Chromium"
	else
		echo -e "\n\n 󰎄 VOID"
	fi
}

# Parse the argument
case "$1" in
--title)
	title=$(get_metadata "xesam:title")
	if [ -z "$title" ]; then
		echo ""
	else
		ten="          "
		thirty="$ten$ten$ten"
		len=${#title}
		end="   "
		if ((len>13)); then
			len=13
			end="..."
		fi
		title="${title:0:13}${thirty:0:$((13 - len))}"
		echo "${title}${end}"
	fi
	;;
--arturl)
	url=$(get_metadata "mpris:artUrl")
	if [ -z "$url" ]; then
		echo ""
	else
		if [[ "$url" == file://* ]]; then
			url=${url#file://}
		elif [[ "$url" == https://i.scdn.co/* ]]; then
			cd "$HOME/.config/hypr/hyprlock/assets"
			temp_url=$(echo $url | awk -F '/' '{print $5}')
			if [ ! -f "${temp_url}" ]; then
				rm *[^.jpg][^.sh][^.webp] >/dev/null 2>/dev/null
				wget $url -O $temp_url >/dev/null 2>/dev/null
			fi
			url="$HOME/.config/hypr/hyprlock/assets/${temp_url}"
		fi
		echo "$url"
	fi
	;;
--artist)
	artist=$(get_metadata "xesam:artist")
	if [ -z "$artist" ]; then
		echo ""
	else
		ten="          "
		thirty="$ten$ten$ten"
		len=${#artist}
		end="   "
		if ((len>10)); then
			len=10
			end="..."
		fi
		artist="${artist:0:10}${thirty:0:$((10 - len))}"
		echo " ${artist}${end}"
	fi
	;;
--length)
	length=$(get_metadata "mpris:length")
	if [ -z "$length" ]; then
		echo ""
	else
		# Convert length from microseconds to a more readable format (seconds)
		echo "$(echo "scale=2; $length / 1000000 / 60" | bc) m"
	fi
	;;
--status)
	status=$(playerctl status 2>/dev/null)
	if [[ $status == "Playing" ]]; then
		echo "󰎆"
	elif [[ $status == "Paused" ]]; then
		echo "󱖐"
	else
		echo ""
	fi
	;;
--album)
	album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
	if [[ -n $album ]]; then
		echo "$album"
	else
		status=$(playerctl status 2>/dev/null)
		if [[ -n $status ]]; then
			echo "Not album"
		else
			echo ""
		fi
	fi
	;;
--source)
	get_source_info
	;;
*)
	echo "Invalid parameter: $1"
	echo "Usage: $0 --title | --arturl | --artist | --length | --album | --source | --status"
	exit 1
	;;
esac

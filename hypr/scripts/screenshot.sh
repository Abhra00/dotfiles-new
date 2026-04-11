#!/usr/bin/env bash
#  ┏┓┏┓┳┓┏┓┏┓┳┓┏┓┓┏┏┓┏┳┓
#  ┗┓┃ ┣┫┣ ┣ ┃┃┗┓┣┫┃┃ ┃
#  ┗┛┗┛┛┗┗┛┗┛┛┗┗┛┛┗┗┛ ┻
#

# Options
option_1=$(printf '\ue85b')
option_2=$(printf '\uf7d2')
option_3=$(printf '\ue06b')
option_4=$(printf '\uf07b')
option_5=$(printf '\uf07a')
option_6=$(printf '\ue792')
option_7=$(printf '\uf524')

# variables
time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"

iDIR="$HOME/.config/mako/assets/"
sDIR="$HOME/.config/hypr/scripts"

active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
active_window_file="Screenshot_${time}_${active_window_class}.png"
active_window_path="${dir}/${active_window_file}"

satty_file="Screenshot_${time}_satty.png"

notify_cmd_base="notify-send -u normal -A action1=Open -A action2=Delete -e -h string:x-canonical-private-synchronous:shot-notify"
notify_cmd_shot="${notify_cmd_base} -i ${iDIR}/ss.svg"
notify_cmd_shot_win="${notify_cmd_base} -i ${iDIR}/ss.svg"
notify_cmd_NOT="notify-send -u low -i ${iDIR}/bell.svg"

# Rofi theme elements
list_col='1'
list_row='7'
win_width='120px'

# Rofi CMD
rofi_cmd() {
    rofi -theme-str "window {width: $win_width;}" \
        -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -dmenu \
        -markup-rows \
        -theme $HOME/.config/rofi/screenShot.rasi
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_7" | rofi_cmd
}

# notify and view screenshot
notify_view() {
    if [[ "$1" == "active" ]]; then
        if [[ -e "${active_window_path}" ]]; then
            "${sDIR}/sounds.sh" --screenshot
            resp=$(timeout 5 ${notify_cmd_shot_win} "Screenshot of:" "${active_window_class} Saved.")
            case "$resp" in
            action1)
                xdg-open "${active_window_path}" &
                ;;
            action2)
                rm "${active_window_path}" &
                ;;
            esac
        else
            ${notify_cmd_NOT} "Screenshot of:" "${active_window_class} NOT Saved."
            "${sDIR}/sounds.sh" --error
        fi

    elif [[ "$1" == "satty" ]]; then
        "${sDIR}/sounds.sh" --screenshot
        resp=$(${notify_cmd_shot} "Screenshot:" "Captured by Satty")
        case "$resp" in
        action1)
            satty -f - -o ${dir}/${satty_file} <"$tmpfile"
            ;;
        action2)
            rm "$tmpfile"
            ;;
        esac

    else
        local check_file="${dir}/${file}"
        if [[ -e "$check_file" ]]; then
            "${sDIR}/sounds.sh" --screenshot
            resp=$(timeout 5 ${notify_cmd_shot} "Screenshot" "Saved")
            case "$resp" in
            action1)
                xdg-open "${check_file}" &
                ;;
            action2)
                rm "${check_file}" &
                ;;
            esac
        else
            ${notify_cmd_NOT} "Screenshot" "NOT Saved"
            "${sDIR}/sounds.sh" --error
        fi
    fi
}

# countdown
countdown() {
    for sec in $(seq $1 -1 1); do
        "${sDIR}/sounds.sh" --countdown &
        notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR"/timer.svg " Taking shot" " in: $sec secs"
        sleep 1
    done
}

# take shots
shotnow() {
    cd ${dir} && grim - | tee "$file" | wl-copy
    sleep 2
    notify_view
}

shot3() {
    countdown '3'
    sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
    sleep 1
    notify_view
}

shot10() {
    countdown '10'
    sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
    notify_view
}

shotwin() {
    w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
    w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
    cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
    notify_view
}

shotarea() {
    tmpfile=$(mktemp)
    grim -g "$(slurp)" - >"$tmpfile"

    # Copy with saving
    if [[ -s "$tmpfile" ]]; then
        wl-copy <"$tmpfile"
        mv "$tmpfile" "$dir/$file"
    fi
    notify_view
}

shotactive() {
    active_window_class=$(hyprctl -j activewindow | jq -r '(.class)')
    active_window_file="Screenshot_${time}_${active_window_class}.png"
    active_window_path="${dir}/${active_window_file}"

    hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | grim -g - "${active_window_path}"
    sleep 1
    notify_view "active"
}

shotsatty() {
    tmpfile=$(mktemp)
    grim -g "$(slurp)" - >"$tmpfile"

    # Copy without saving
    if [[ -s "$tmpfile" ]]; then
        wl-copy <"$tmpfile"
        notify_view "satty"
    fi
}

# Check if dir exist or not
if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
fi

# Execute Command
run_cmd() {
    if [[ "$1" == '--opt1' ]]; then
        shotnow
    elif [[ "$1" == '--opt2' ]]; then
        shotarea
    elif [[ "$1" == '--opt3' ]]; then
        shotwin
    elif [[ "$1" == '--opt4' ]]; then
        shot3
    elif [[ "$1" == '--opt5' ]]; then
        shot10
    elif [[ "$1" == '--opt6' ]]; then
        shotactive
    elif [[ "$1" == '--opt7' ]]; then
        shotsatty
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$option_1)
    run_cmd --opt1
    ;;
$option_2)
    run_cmd --opt2
    ;;
$option_3)
    run_cmd --opt3
    ;;
$option_4)
    run_cmd --opt4
    ;;
$option_5)
    run_cmd --opt5
    ;;
$option_6)
    run_cmd --opt6
    ;;
$option_7)
    run_cmd --opt7
    ;;
esac

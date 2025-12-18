#    ┏┓┏┓┳┓┏┓┳┏┓
#    ┃ ┃┃┃┃┣ ┃┃┓
#    ┗┛┗┛┛┗┻ ┻┗┛

# Greeting
if status is-interactive
    if test (tty) = /dev/tty1
        if test -f /bin/hyprland
            echo "Start hyprland with Hyprland"
        end
    else
        fastfetch -c $HOME/.config/fastfetch/config.jsonc
        echo ""
    end
end

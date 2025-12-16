#    ┏┓┏┓┳┓┏┓┳┏┓
#    ┃ ┃┃┃┃┣ ┃┃┓
#    ┗┛┗┛┛┗┻ ┻┗┛

# Greeting
set -g fish_greeting "Welcome, $USER ✨"
if status is-interactive
    if test (tty) = /dev/tty1
        if test -f /bin/hyprland
            echo "Start hyprland with Hyprland"
        end
    else
        fastfetch -c $HOME/.config/fastfetch/config.jsonc
    end
end

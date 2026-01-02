#    ┓┏┓┏┏┓┳┓┏┓┓┏┏┓┳┓
#    ┣┫┗┫┃┃┣┫┃ ┣┫┣┫┃┃
#    ┛┗┗┛┣┛┛┗┗┛┛┗┛┗┻┛
#

# Auto start Hyprland on tty1
if test -z "$DISPLAY"; and test "$XDG_VTNR" -eq 1
    if not test -d ~/.cache
        mkdir ~/.cache
    end
    exec start-hyprland >~/.cache/hyprland.log 2>&1
end

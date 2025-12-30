#    ┓┏┓┏┏┓┳┓┏┓┓┏┏┓┳┓
#    ┣┫┗┫┃┃┣┫┃ ┣┫┣┫┃┃
#    ┛┗┗┛┣┛┛┗┗┛┛┗┛┗┻┛
#

# Start Hyprland on TTY1
if test -z "$WAYLAND_DISPLAY"; and test "$XDG_VTNR" = 1
    start-hyprland
end

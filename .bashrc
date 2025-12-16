#  ┳┓┏┓┏┓┓┏┳┓┏┓
#  ┣┫┣┫┗┓┣┫┣┫┃
#  ┻┛┛┗┗┛┛┗┛┗┗┛
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load my modular bashrc
if [ -f "$HOME/.config/bashrc/rc" ]; then
  . "$HOME/.config/bashrc/rc"
fi

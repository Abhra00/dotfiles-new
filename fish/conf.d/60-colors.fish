# ┏┓┏┓┓ ┏┓┳┓┏┓
# ┃ ┃┃┃ ┃┃┣┫┗┓
# ┗┛┗┛┗┛┗┛┛┗┗┛
#

# Kintsukuroi colors
set -l foreground e5c9a0
set -l selection 4d463e
set -l comment 5a5147
set -l red c06c5c
set -l green 78997a
set -l yellow c09d59
set -l blue 7f91b2
set -l magenta b380b0
set -l cyan 7b9695

# Syntax highlighting colors
set -g fish_color_normal $foreground
set -g fish_color_command $green
set -g fish_color_keyword $blue
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $blue
set -g fish_color_option $blue
set -g fish_color_error $red
set -g fish_color_param $magenta
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $yellow
set -g fish_color_escape $blue
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection

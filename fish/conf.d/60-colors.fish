# ┏┓┏┓┓ ┏┓┳┓┏┓
# ┃ ┃┃┃ ┃┃┣┫┗┓
# ┗┛┗┛┗┛┗┛┛┗┗┛
#

# Everblush palette
set -l foreground dadada
set -l selection 2d3437
set -l comment 404749
set -l red e57474
set -l green 8ccf7e
set -l yellow e5c76b
set -l blue 67b0e8
set -l magenta c47fd5
set -l cyan 6cbfbf

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
set -g fish_color_operator $green
set -g fish_color_escape $blue
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection

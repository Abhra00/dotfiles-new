# ┏┓┏┓┓ ┏┓┳┓┏┓
# ┃ ┃┃┃ ┃┃┣┫┗┓
# ┗┛┗┛┗┛┗┛┛┗┗┛
#

# Nagi palette
set -l foreground e2e5e6
set -l selection 2c3334
set -l comment 414c4d
set -l red d95762
set -l green a6d98d
set -l yellow f38c61
set -l blue 95b7e6
set -l magenta d282d9
set -l cyan 92e2f2

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

# ┏┓┏┓┓ ┏┓┳┓┏┓
# ┃ ┃┃┃ ┃┃┣┫┗┓
# ┗┛┗┛┗┛┗┛┛┗┗┛
#

# TokyoNight Color Palette
set -l foreground C0CAF5
set -l selection 292E42
set -l comment 565F89
set -l red DB4B4B
set -l orange FF9E64
set -l yellow E0AF68
set -l green 9FE044
set -l magenta FF007C
set -l cyan 7DCFFF
set -l teal 1ABC9C

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $teal
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_option $teal
set -g fish_color_error $red
set -g fish_color_param $magenta
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $teal
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection

#    ┏┓┏┓┓ ┏┓┳┓┏┓
#    ┃ ┃┃┃ ┃┃┣┫┗┓
#    ┗┛┗┛┗┛┗┛┛┗┗┛
#

# solarized-osaka Color Palette
set -l foreground 839395
set -l selection 1A6397
set -l base01 576D74
set -l red DB302D
set -l orange C94C16
set -l yellow B28500
set -l green 849900
set -l blue 46ACF5
set -l cyan 29A298
set -l pink D23681

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $blue
set -g fish_color_comment $base01
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $base01

# Completion Pager Colors
set -g fish_pager_color_progress $base01
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $base01
set -g fish_pager_color_selected_background --background=$selection

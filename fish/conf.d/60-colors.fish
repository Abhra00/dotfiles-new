# ┏┓┏┓┓ ┏┓┳┓┏┓
# ┃ ┃┃┃ ┃┃┣┫┗┓
# ┗┛┗┛┗┛┗┛┛┗┗┛
#

# Lunaris colors
set -l foreground f6f6f5
set -l selection 233440
set -l comment b186bf
set -l red dd6e6b
set -l green 87e58e
set -l yellow e8eda2
set -l blue baa0e8
set -l magenta e48cc1
set -l cyan a7dfef

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

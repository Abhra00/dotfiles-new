#    ┳┳┓┳┏┳┓
#    ┃┃┃┃ ┃
#    ┻┛┗┻ ┻

# Starship
if command -q starship
    starship init fish | source
end

# Zoxide
if command -q zoxide
    zoxide init fish | source
end

# FZF
if command -q fzf
    fzf --fish | source
end

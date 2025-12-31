#    ┳┳┓┳┏┳┓
#    ┃┃┃┃ ┃
#    ┻┛┗┻ ┻

# Pyenv
if command -q pyenv
    pyenv init - | source
end

# Zoxide
if command -q zoxide
    zoxide init fish | source
end

# FZF
if command -q fzf
    fzf --fish | source
end

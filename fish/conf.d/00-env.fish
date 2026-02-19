#    ┏┓┳┓┓┏
#    ┣ ┃┃┃┃
#    ┗┛┛┗┗┛
#

# Suppress fish greetings message
set -gx fish_greeting ""

# Programs & Editors
set -gx TERMINAL ghostty
set -gx BROWSER chromium
set -gx EDITOR nvim
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME Kintsukuroi

# XDG Base Directories
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache

# ~/ Clean-up
set -gx NOTMUCH_CONFIG $XDG_CONFIG_HOME/notmuch-config
set -gx GTK2_RC_FILES $XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0
set -gx WGETRC $XDG_CONFIG_HOME/wget/wgetrc
set -gx GNUPGHOME $XDG_DATA_HOME/gnupg
set -gx WINEPREFIX $XDG_DATA_HOME/wineprefixes/default
set -gx KODI_DATA $XDG_DATA_HOME/kodi
set -gx PASSWORD_STORE_DIR $XDG_DATA_HOME/password-store
set -gx TMUX_TMPDIR $XDG_RUNTIME_DIR
set -gx ANDROID_SDK_HOME $XDG_CONFIG_HOME/android
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
set -gx GOPATH $XDG_DATA_HOME/go
set -gx GOMODCACHE $XDG_CACHE_HOME/go/mod
set -gx ANSIBLE_CONFIG $XDG_CONFIG_HOME/ansible/ansible.cfg
set -gx UNISON $XDG_DATA_HOME/unison
set -gx HISTFILE $XDG_DATA_HOME/history
set -gx MBSYNCRC $XDG_CONFIG_HOME/mbsync/config
set -gx NPM_CONFIG_USERCONFIG $HOME/.config/npm/npmrc
set -gx ELECTRUMDIR $XDG_DATA_HOME/electrum
set -gx PYTHONSTARTUP $XDG_CONFIG_HOME/python/pythonrc
set -gx SQLITE_HISTORY $XDG_DATA_HOME/sqlite_history
set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml

# Set pyenv root path
set -gx PYENV_ROOT $XDG_DATA_HOME/.pyenv

# PATH modifications
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.config/hypr/scripts
fish_add_path $CARGO_HOME/bin
fish_add_path $HOME/.local/share/npm/bin
fish_add_path $PYENV_ROOT/bin

# FZF opts
set -gx FZF_DEFAULT_COMMAND "fd . --max-depth=1 --hidden"
set -gx FZF_DEFAULT_OPTS " \
  $FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --scrollbar='▓' \
  --marker=' ' \
  --ellipsis='… ' \
  --prompt='  ' \
  --pointer='' \
  --color=bg+:#322d28 \
  --color=fg+:#e5c9a0 \
  --color=bg:-1 \
  --color=border:#7f91b2 \
  --color=fg:#e5c9a0 \
  --color=header:#7b9695 \
  --color=hl+:#d88095 \
  --color=hl:#d88095 \
  --color=info:#c09d59 \
  --color=marker:#c06c5c \
  --color=pointer:#7f91b2 \
  --color=prompt:#7f91b2 \
  --color=gutter:#141210 \
  --color=query:#e5c9a0:regular \
  --color=scrollbar:#4d463e \
  --color=separator:#4d463e \
  --color=spinner:#c09d59 \
"


# Misc
set -gx SUDO_ASKPASS $HOME/.local/bin/rofipass
set -gx LESS R
set -gx LESS_TERMCAP_mb (printf '\e[01;31m')
set -gx LESS_TERMCAP_md (printf '\e[01;31m')
set -gx LESS_TERMCAP_me (printf '\e[0m')
set -gx LESS_TERMCAP_se (printf '\e[0m')
set -gx LESS_TERMCAP_so (printf '\e[01;30;44m')
set -gx LESS_TERMCAP_ue (printf '\e[0m')
set -gx LESS_TERMCAP_us (printf '\e[01;32m')
set -gx LESSOPEN '| bat --style=plain --paging=never --color=always -- %s 2>/dev/null'

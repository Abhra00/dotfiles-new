#  ┏┓┏┓┓┏┳┓┏┓
#  ┏┛┗┓┣┫┣┫┃
#  ┗┛┗┛┛┗┛┗┗┛
#


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


#  ┏┓┓ ┳┏┓┏┓┏┓┏┓
#  ┣┫┃ ┃┣┫┗┓┣ ┗┓
#  ┛┗┗┛┻┛┗┗┛┗┛┗┛
#
[[ -r ${ZDOTDIR:-$HOME}/zaliases ]] && source ${ZDOTDIR:-$HOME}/zaliases


#  ┏┓┳┓┏┓┳┳┓┏┓
#  ┣ ┃┃┃┓┃┃┃┣
#  ┗┛┛┗┗┛┻┛┗┗┛
#
autoload -Uz compinit

for dump in ~/.config/zsh/zcompdump(N.mh+24); do
  compinit -d ~/.config/zsh/zcompdump
done

compinit -C -d ~/.config/zsh/zcompdump
autoload -Uz colors && colors # Enabling colors
autoload -Uz add-zsh-hook     # Adding zsh hook for custom functions
autoload -Uz vcs_info         # Enabling vcs_info
_comp_options+=(globdots)


#  ┏┓┏┓┳┳┓┏┓┓ ┏┓┏┳┓┳┏┓┳┓  ┏┓┏┳┓┓┏┓ ┏┓┏┓
#  ┃ ┃┃┃┃┃┃┃┃ ┣  ┃ ┃┃┃┃┃  ┗┓ ┃ ┗┫┃ ┣ ┗┓
#  ┗┛┗┛┛ ┗┣┛┗┛┗┛ ┻ ┻┗┛┛┗  ┗┛ ┻ ┗┛┗┛┗┛┗┛
#
# Completion menu and fzf stuff
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:default' list-colors ${(s.:.)ZLS_COLORS} 'ma=1\;33'
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  '+r:|[._-]=* r:|=*' \
  '+l:|=*'
zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' \
  --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:yellow:bold' \
  --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
  --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
  --preview-label ' Preview ' --color 'preview-border:magenta,preview-label:magenta:bold'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

# Vcs info styling
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' miscstr '● '
zstyle ':vcs_info:git:*' unstagedstr '✱ '
zstyle ':vcs_info:git:*' stagedstr '✦ '
zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}[%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%}]%{$reset_color%}"

#  ┓ ┏┏┓┳┏┳┓┳┳┓┏┓  ┳┓┏┓┏┳┓┏┓
#  ┃┃┃┣┫┃ ┃ ┃┃┃┃┓  ┃┃┃┃ ┃ ┗┓
#  ┗┻┛┛┗┻ ┻ ┻┛┗┗┛  ┻┛┗┛ ┻ ┗┛
#
expand-or-complete-with-dots() {
  echo -n "\e[31m…\e[0m"
  zle expand-or-complete
  zle redisplay
}

zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

#  ┏┓┏┓┳┳┓┳┳┓┏┓┳┓┳┓  ┳┓┏┓┏┳┓  ┏┓┏┓┳┳┳┓┳┓  ┓┏┏┓┳┓┳┓┓ ┏┓┳┓
#  ┃ ┃┃┃┃┃┃┃┃┣┫┃┃┃┃  ┃┃┃┃ ┃   ┣ ┃┃┃┃┃┃┃┃  ┣┫┣┫┃┃┃┃┃ ┣ ┣┫
#  ┗┛┗┛┛ ┗┛ ┗┛┗┛┗┻┛  ┛┗┗┛ ┻   ┻ ┗┛┗┛┛┗┻┛  ┛┗┛┗┛┗┻┛┗┛┗┛┛┗
#
command_not_found_handler() {
	printf "%s%s? WTF!!  you are typing\n" "$acc" "$0" >&2
    	return 127
}



#  ┓┏┳┏┓┏┳┓┏┓┳┓┓┏
#  ┣┫┃┗┓ ┃ ┃┃┣┫┗┫
#  ┛┗┻┗┛ ┻ ┗┛┛┗┗┛
#
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups



#  ┏┓┏┓┏┓┓   ┏┓┏┓┏┳┓┳┏┓┳┓┏┓
#  ┃ ┃┃┃┃┃   ┃┃┃┃ ┃ ┃┃┃┃┃┗┓
#  ┗┛┗┛┗┛┗┛  ┗┛┣┛ ┻ ┻┗┛┛┗┗┛
#
setopt interactive_comments # Interactive comments
stty stop undef             # Disable ctrl-s for frezzing terminal
setopt AUTOCD               # Change directory just by typing its name
setopt PROMPT_SUBST         # enable command substitution in prompt
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt LIST_PACKED	    	# The completion menu takes less space.
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

#  ┓┏┳┳┳┓  ┳┳┓┏┓┳┓┏┓  ┏┓  ┓┏┓┏┓┓┏┳┓┳┳┓┳┓┏┓
#  ┃┃┃┃┃┃━━┃┃┃┃┃┃┃┣   ┣╋  ┃┫ ┣ ┗┫┣┫┃┃┃┃┃┗┓
#  ┗┛┻┛ ┗  ┛ ┗┗┛┻┛┗┛  ┗┻  ┛┗┛┗┛┗┛┻┛┻┛┗┻┛┗┛
#
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[1 q';; # block
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[1 q"
}
zle -N zle-line-init
echo -ne '\e[1 q' # Use block shape cursor on startup.
preexec() { echo -ne '\e[1 q' ;} # Use block shape cursor for each new prompt.

# Basic binds deleting char both in normal or vi mode
bindkey '^[[3~' delete-char
bindkey -v '^?' backward-delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Vicmd specific binds
bindkey -M vicmd '^e' edit-command-line
bindkey -M vicmd '^?' vi-delete-char
bindkey -M visual '^?' vi-delete-char

# Additionaly set up basic Emacs-style navigation
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' forward-char
bindkey '^B' backward-char

#  ┓┏┏┓┏┓┳  ┏┓┳┳┳┓┏┓┏┓  ┏┓  ┳┓┳┳┓┳┓┏┓
#  ┗┫┣┫┏┛┃  ┣ ┃┃┃┃┃ ┗┓  ┣╋  ┣┫┃┃┃┃┃┗┓
#  ┗┛┛┗┗┛┻  ┻ ┗┛┛┗┗┛┗┛  ┗┻  ┻┛┻┛┗┻┛┗┛
#
yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

yazicd_widget() {
    zle -I
    yy
}

zle -N yazicd_widget
bindkey '^O' yazicd_widget

#    ┳┳┏┳┓┳┓ ┳┏┳┓┓┏  ┏┓┳┳┳┓┏┓┏┓
#    ┃┃ ┃ ┃┃ ┃ ┃ ┗┫━━┣ ┃┃┃┃┃ ┗┓
#    ┗┛ ┻ ┻┗┛┻ ┻ ┗┛  ┻ ┗┛┛┗┗┛┗┛
#
[[ -r ${ZDOTDIR:-$HOME}/functions.zsh ]] && source ${ZDOTDIR:-$HOME}/functions.zsh

#  ┏┓┳┳┳┓┏┓  ┏┓┳┓┏┓┳┳┓┏┓┏┳┓
#  ┗┓┃┃┃┃┃┃  ┃┃┣┫┃┃┃┃┃┃┃ ┃
#  ┗┛┗┛┻┛┗┛  ┣┛┛┗┗┛┛ ┗┣┛ ┻
#
export SUDO_PROMPT="$fg[white]Deploying $fg[magenta]root access for %u $fg[blue]password pls: $fg[white]"



#  ┏┳┓┓┏┏┓  ┏┓┳┓┏┓┳┳┓┏┓┏┳┓
#   ┃ ┣┫┣   ┃┃┣┫┃┃┃┃┃┃┃ ┃
#   ┻ ┛┗┗┛  ┣┛┛┗┗┛┛ ┗┣┛ ┻
#
+vi-git-untracked(){
   if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
       git status --porcelain | grep '??' &> /dev/null ; then
       hook_com[staged]+='!' # signify new files with a bang
   fi
}
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
precmd_new_line() { echo "" }
precmd_functions+=( precmd_new_line )

PROMPT="%b%{$fg[magenta]%}λ % %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+="\$vcs_info_msg_0_ "

#  ┏┓┓ ┳┳┏┓┳┳┓┏┓  ┏┓  ┏┓┓ ┳┳┏┓┳┳┓  ┏┓┏┓┏┓┏┓┳┏┓┳┏┓  ┓┏┓┏┓┓┏┳┓┳┳┓┳┓┏┓
#  ┃┃┃ ┃┃┃┓┃┃┃┗┓  ┣╋  ┃┃┃ ┃┃┃┓┃┃┃  ┗┓┃┃┣ ┃ ┃┣ ┃┃   ┃┫ ┣ ┗┫┣┫┃┃┃┃┃┗┓
#  ┣┛┗┛┗┛┗┛┻┛┗┗┛  ┗┻  ┣┛┗┛┗┛┗┛┻┛┗  ┗┛┣┛┗┛┗┛┻┻ ┻┗┛  ┛┗┛┗┛┗┛┻┛┻┛┗┻┛┗┛
#
# basic plugin manager to automatically import zsh plugins
# script by mattmc3 from https://github.com/mattmc3/zsh_unplugged
# clone a plugin, identify its init file, source it, and add it to your fpath
function plugin-load {
	local repo plugdir initfile initfiles=()
	: ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/plugins}
	for repo in $@; do
		plugdir=$ZPLUGINDIR/${repo:t}
		initfile=$plugdir/${repo:t}.plugin.zsh
		if [[ ! -d $plugdir ]]; then
			echo "Cloning $repo..."
			git clone -q --depth 1 --recursive --shallow-submodules \
				https://github.com/$repo $plugdir
		fi
		if [[ ! -e $initfile ]]; then
			initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
			(( $#initfiles )) || { echo >&2 "No init file '$repo'." && continue }
			ln -sf $initfiles[1] $initfile
		fi
		fpath+=$plugdir
		(( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
	done
}

# list of github repos of plugins
repos=(
	Aloxaf/fzf-tab
	zdharma-continuum/fast-syntax-highlighting
	zsh-users/zsh-autosuggestions
	zsh-users/zsh-history-substring-search
)
plugin-load $repos

# Binds for histroty substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#  ┏┓┓┏┏┓┓ ┓   ┳┳┓┏┳┓┏┓┏┓┳┓┏┓┏┳┓┳┏┓┳┓
#  ┗┓┣┫┣ ┃ ┃   ┃┃┃ ┃ ┣ ┃┓┣┫┣┫ ┃ ┃┃┃┃┃
#  ┗┛┛┗┗┛┗┛┗┛  ┻┛┗ ┻ ┗┛┗┛┛┗┛┗ ┻ ┻┗┛┛┗
#
eval "$(zoxide init zsh)"
source <(fzf --zsh)

#  ┏┓┳┳┏┳┓┏┓┏┓┏┳┓┏┓┳┓┏┳┓
#  ┣┫┃┃ ┃ ┃┃┗┓ ┃ ┣┫┣┫ ┃
#  ┛┗┗┛ ┻ ┗┛┗┛ ┻ ┛┗┛┗ ┻
#
# Load custom fast syntax highlighting theme
[[ -r ${ZDOTDIR:-$HOME}/fsh_theme.ini ]] && fast-theme ${ZDOTDIR:-$HOME}/fsh_theme.ini > /dev/null
# Fetch
echo ""
figlet -f slant "Endeavour OS"
fastfetch

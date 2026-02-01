# ┏┓┏┓┏┓  ┳┓┳┓┏┓┓ ┏┏┓┏┓
# ┣ ┏┛┣ ━━┣┫┣┫┃┃┃┃┃┗┓┣ 
# ┻ ┗┛┻   ┻┛┛┗┗┛┗┻┛┗┛┗┛
#
function _fzf_file_or_directory
  commandline -f repaint
  fzf \
    --preview 'if test -d {}
        printf "\033_Ga=d\033\\\\"
        eza --tree --level=2 --color=always --icons {} 2>/dev/null; or command ls -lah {}
      else if file --mime-type {} | grep -q image/
        printf "\033_Ga=d\033\\\\"
        set cols $FZF_PREVIEW_COLUMNS
        set lines $FZF_PREVIEW_LINES
        if set -q TMUX
          chafa --format=kitty --passthrough=tmux --size={$cols}x{$lines} {} 2>/dev/null
        else
          chafa --format=kitty --size={$cols}x{$lines} {} 2>/dev/null
        end
      else
        printf "\033_Ga=d\033\\\\"
        bat --style=numbers --color=always {} 2>/dev/null; or cat {}
      end' \
    --preview-window=right:60%:wrap:border-sharp \
    --height=80% \
    --border=sharp \
    --prompt="  Files & Dirs " \
    --header="Enter: insert path | Ctrl-E: nvim | Ctrl-D: delete | ESC: exit" \
    --bind='ctrl-e:execute(nvim {})+abort' \
    --bind='ctrl-d:execute(rm -i {})+reload(fd -d 3 . $PWD)' \
  | perl -pe 's/([ ()])/\\$1/g' | read -l selection
  
  printf "\033_Ga=d\033\\\\"
  
  if test -n "$selection"
    set current_cmd (commandline -b)
    
    if test -d "$selection"
      if test -z "$current_cmd"
        builtin cd "$selection"
        commandline -r ''
        commandline -f repaint
      else
        commandline -i ""(string escape -- $selection)
      end
    else
      if test -z "$current_cmd"
        commandline -r "xdg-open "(string escape -- $selection)
      else
        commandline -i ""(string escape -- $selection)
      end
    end
  else
    commandline ''
  end
end

function fzf_browse
  fd -H -L -d 3 . . 2>/dev/null \
  | sed 's|^\./||' \
  | _fzf_file_or_directory
end

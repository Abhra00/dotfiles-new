#!/usr/bin/env bash
#  ┏┓┓┏┏┓┳┳┓┏┓┏┓
#  ┗┓┗┫┗┓┃┃┃┣ ┃┃
#  ┗┛┗┛┗┛┻┛┗┻ ┗┛
#
#
#

# Use blocks script
blocks.sh

# Find os name
OS=$(grep '^NAME=' /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')

# Find init system
find_init() {
  if pidof systemd &>/dev/null; then
    printf 'SystemD'
  elif [[ -f /sbin/openrc ]]; then
    printf 'OpenRC'
  else
    file='/proc/1/comm'
    if [[ -r $file ]]; then
      read data <"$file"
      printf '%s' "${data%% *}"
    else
      printf '?'
    fi
  fi
}

# Find package count
### ADD YOUR OWN LINE IF YOUR MANAGER IS NOT LISTED
pkg_count() {
  for pkg_mgr in xbps-install apt pacman; do
    type -P "$pkg_mgr" &>/dev/null || continue

    case $pkg_mgr in
    xbps-install)
      xbps-query -l | wc -l
      ;;
    apt)
      while read abbrev _; do
        [[ $abbrev == ii ]] && ((line_count++))
      done <<<"$(dpkg -l)"
      printf '%d' $line_count
      ;;
    pacman)
      pkgs=$(pacman -Q | wc -l)
      printf '%d' "$pkgs"
      ;;
    esac
    return
  done
  printf 'Not Found'
}


# WM Name
WM_NAME=$(xprop -root _NET_SUPPORTING_WM_CHECK \
  | awk -F '#' '{print $2}' \
  | xargs -I {} xprop -id {} _NET_WM_NAME \
  | cut -d '"' -f2)

[[ "$WM_NAME" == "LG3D" ]] && WM_NAME="Qtile" 

# Config

# Border padding
left_up=30
right_up=30
left_dn=32
right_dn=32

# Print it
printf "%0.s-" $(seq 1 $left_up)
printf "\033[44;30m SYSINFO \e[0m"
printf "%0.s-" $(seq 1 $right_up)
printf "\n\n"

printf '       [ LSB: \e[33m%s\e[0m ] \e[0m' "$OS"
printf '[ INIT: \e[32m%s \e[0m] ' "$(find_init)"
printf '[ PKGs: \e[34m%s \e[0m] ' "$(pkg_count)"
printf '\n\n'
printf '       	    [ WM: \e[35m%s \e[0m] ' "$WM_NAME"
printf '[ SHELL: \e[36m%s \e[0m] ' "$SHELL"
printf "\n\n"

printf "%0.s-" $(seq 1 $left_dn)
printf "\033[44;30m END \e[0m"
printf "%0.s-" $(seq 1 $right_dn)
printf "\n\n"

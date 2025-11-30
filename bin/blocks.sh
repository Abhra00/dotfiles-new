#!/usr/bin/env bash
#  ┳┓┓ ┏┓┏┓┓┏┓┏┓
#  ┣┫┃ ┃┃┃ ┃┫ ┗┓
#  ┻┛┗┛┗┛┗┛┛┗┛┗┛
#

f=3 b=4

# Generate escape sequences for normal and bright foreground colors
for j in f b; do
    for i in {0..7}; do
        printf -v ${j}${i} "\e[${!j}${i}m"
    done
done
for i in {0..7}; do
    printf -v fbright${i} "\e[9${i}m"
done

# Formatting codes
reset=$'\e[0m'
white_bg=$'\e[47m'

# Print 2 rows of combined dark & bright blocks with tab spacing
for row in {1..2}; do
    printf "\t"
    for i in {0..7}; do
        var_dark="f${i}"
        var_bright="fbright${i}"
        printf "${!var_dark}███${!var_bright}███${reset} "
    done
    echo
done

# Print bottom white bar under each pair
printf "\t"
for i in {0..7}; do
    printf "${white_bg}      ${reset} "
done
printf "\n\n"

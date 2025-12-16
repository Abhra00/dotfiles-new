#    ┏┓┏┓┳┳┓┏┓┳┓┏┓┏┓┏┓
#    ┃ ┃┃┃┃┃┃┃┣┫┣ ┗┓┗┓
#    ┗┛┗┛┛ ┗┣┛┛┗┗┛┗┛┗┛
#
function compress
    set target (string replace -r '/$' '' $argv[1])
    tar -czf "$target.tar.gz" $target
end

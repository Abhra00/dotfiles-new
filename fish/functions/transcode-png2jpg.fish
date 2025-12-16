#    ┏┳┓┳┓┏┓┳┓┏┓┏┓┏┓┳┓┏┓  ┏┓┳┓┏┓┏┓┏┳┏┓┏┓
#     ┃ ┣┫┣┫┃┃┗┓┃ ┃┃┃┃┣ ━━┃┃┃┃┃┓┏┛ ┃┃┃┃┓
#     ┻ ┛┗┛┗┛┗┗┛┗┛┗┛┻┛┗┛  ┣┛┛┗┗┛┗━┗┛┣┛┗┛
#
function transcode-png2jpg
    set base (path change-extension '' $argv[1])
    magick $argv[1] -quality 95 -strip "$base.jpg"
end

#    ┏┳┓┳┓┏┓┳┓┏┓┏┓┏┓┳┓┏┓  ┓┏┳┳┓┏┓┏┓  ┏┓┓┏┓
#     ┃ ┣┫┣┫┃┃┗┓┃ ┃┃┃┃┣ ━━┃┃┃┃┃┣ ┃┃━━┃┃┃┫
#     ┻ ┛┗┛┗┛┗┗┛┗┛┗┛┻┛┗┛  ┗┛┻┻┛┗┛┗┛  ┗╋┛┗┛
#
function transcode-video-4k
    set base (path change-extension '' $argv[1])
    ffmpeg -i $argv[1] -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "$base-optimized.mp4"
end

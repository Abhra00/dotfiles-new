#    ┏┓┏┓┳┓┳┳┓┏┓┏┳┓  ┳┓┳┓┳┓┏┏┓
#    ┣ ┃┃┣┫┃┃┃┣┫ ┃ ━━┃┃┣┫┃┃┃┣
#    ┻ ┗┛┛┗┛ ┗┛┗ ┻   ┻┛┛┗┻┗┛┗┛
#
function format-drive
    if test (count $argv) -ne 2
        echo "Usage: format-drive <device> <name>"
        echo "Example: format-drive /dev/sda 'My Stuff'"
        echo -e "\nAvailable drives:"
        lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
        return 1
    end

    echo "WARNING: This will completely erase all data on $argv[1] and label it '$argv[2]'."
    read -P "Are you sure you want to continue? (y/N): " -l confirm

    if test "$confirm" = y -o "$confirm" = Y
        sudo wipefs -a $argv[1]
        sudo dd if=/dev/zero of=$argv[1] bs=1M count=100 status=progress
        sudo parted -s $argv[1] mklabel gpt
        sudo parted -s $argv[1] mkpart primary ext4 1MiB 100%

        if string match -q "*nvme*" $argv[1]
            set partition "$argv[1]p1"
        else
            set partition "$argv[1]1"
        end

        sudo mkfs.ext4 -L $argv[2] $partition
        echo "Drive $argv[1] formatted and labeled '$argv[2]'."
    end
end

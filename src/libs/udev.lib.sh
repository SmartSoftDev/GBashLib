function get_udev_info_by_dev(){
    local dev_path
    dev_path="$1"
    udevadm info -a -p  $(udevadm info -q path -n $dev_path)
}
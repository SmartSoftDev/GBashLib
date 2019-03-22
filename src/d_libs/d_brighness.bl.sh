function _set_brigtness(){
    local value="$1"
    local output="$(v get -t config MONITOR_OUTPUT)"
    echo "xrandr --output $output --brightness $value"
    xrandr --output $output --brightness $value

}
gblcmd_descr_set_brightness='Sets brightness of "xrands --output" configured in "$(v get -t config MONITOR_OUTPUT)"'
gblcmd_set_brightness(){
    _set_brigtness "$1"
}
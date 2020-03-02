. $(gbl log)
function _togle_touchpad(){
    local cmd="$1" #shold be enable or disable
    local touchpad_id=$(xinput list --id-only "$(v get -t config TOUCHPAD_NAME)")
    [ "$touchpad_id" == "" ] && fatal "touchbad not set: v set -t config TOUCHPAD_NAME=?"
    echo "xinput $cmd $touchpad_id"
    xinput $cmd $touchpad_id
}

gblcmd_descr_touchpad_enable='ENABLES xinput device configured in $(v get -t config TOUCHPAD_NAME)'
gblcmd_touchpad_enable(){
    _togle_touchpad enable
}

gblcmd_descr_touchpad_disable='DISABLES xinput device configured in $(v get -t config TOUCHPAD_NAME)'
gblcmd_touchpad_disable(){
    _togle_touchpad disable
}
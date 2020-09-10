. $(gbl log)
function _togle_touchpad(){
    local cmd="$1" #shold be enable or disable
    local touchpad_id=$(xinput list --id-only "$(v get -t config TOUCHPAD_NAME)")
    [ "$touchpad_id" == "" ] && fatal "touchbad not set: v set -t config TOUCHPAD_NAME=?"
    echo "xinput $cmd $touchpad_id"
    xinput $cmd $touchpad_id
}

gblcmd_descr_map_touchscreen_to_display='maps xinput devices to a specific screen'
gblcmd_map_touchscreen_to_display(){
    # get the list of touchscreens
    local touchscreens=($(v list -t touchscreen -n))
    what=""
    for i in ${touchscreens[@]} ; do
        local disp_output=$(v get -t touchscreen $i)
        log "Setting touchscreen: '$i' on output '$disp_output'"
        local xinput_list=touchscreen_xinputs_$i
        local xinput_names=($(v list -t $xinput_list -n))
        for j in ${xinput_names[@]} ; do
            local xinput_search=$(v get -t $xinput_list $j)
            local xinput_id=$(xinput list --id-only "$xinput_search")
            log "set xinput $j (id=$xinput_id) for touchscreen $i ($disp_output)"
            xinput map-to-output $xinput_id $disp_output

        done
    done
}

. $(gbl log)

function systemd_create_or_update_from_tpl(){
    local service_name="$1"
    local tpl_file_path="$2"
    shift
    shift
    # all other arguments will be passed to -v of TPL command

    local service_file=${service_name}.service
    local sysd_file=/lib/systemd/system/$service_file
    if [ -f $sysd_file ];then
        log "stop $service_file"
        sudo systemctl stop $service_file
    fi
    log "generate $sysd_file"
    local v_cmd="-v"
    if [ "$#" -eq 0 ] ; then v_cmd="" ; fi

    sudo tpl -i $tpl_file_path \
            -o $sysd_file \
            $v_cmd $@
    sudo systemctl daemon-reload
    sudo systemctl enable $service_file
    sudo systemctl start $service_file
}
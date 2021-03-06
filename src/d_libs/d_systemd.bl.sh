
. $(gbl log)

gblcmd_descr_ctl='run st,start,stop,restart,list for systemd installed services'
gblcmd_ctl(){
    local services=( )

    if [ "$2" == "" ] ;then
        services=($(v list -t systemd -v))
    else
        services=($(v get -t systemd -s $2))
    fi

    local arg="$1"
    if [ "$1" == "st" ] ; then
        arg="status"
    elif [ "$1" == "start" ] ; then
        arg="start"
    elif [ "$1" == "stop" ] ; then
        arg="stop"
    elif [ "$1" == "restart" ] ; then
        arg="restart"
    elif [ "$1" == "list" ] ; then
        v list -t systemd -v
        return
    else
        fatal "command st,start,stop,restart,list must be specified"
    fi
    local what=""
    for i in ${services[@]} ; do
        what="$what $i"
    done
    log "cmd: $arg services: ${services[@]}"
    sudo systemctl "$arg" $what
}

_log_get_what(){
    services=( )
    if [ "$1" == "" ] ;then
        services=($(v list -t systemd -v))
    else
        services=($(v get -t systemd -s $1))
    fi
    what=""
    for i in ${services[@]} ; do
        what="$what -u $i"
    done

}

gblcmd_descr_log='run journalctl -f -u MATCH_SERVICE1 -u MATCH_SERVICE2 ...'
gblcmd_log(){
    _log_get_what $@
    log "services: ${services[@]}"
    journalctl -f $what
}

gblcmd_descr_log='run journalctl -b -e -u MATCH_SERVICE1 -u MATCH_SERVICE2 ...'
gblcmd_log_boot(){
    _log_get_what $@
    log "services: ${services[@]}"
    journalctl -b -e $what
}

gblcmd_descr_log='run journalctl -e -u MATCH_SERVICE1 -u MATCH_SERVICE2 ...'
gblcmd_log_all(){
    _log_get_what $@
    log "services: ${services[@]}"
    journalctl -e $what
}

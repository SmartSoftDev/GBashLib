function ssh_tunnel(){
    local action="$1"
    local host="$2"
    local local_port="$3"
    local remote_port="$4"
    local remote_host="${5:-127.0.0.1}"
    local mode="-L"
    local tun_name=""
    if [ -n "$6" ]; then 
        mode="-R" ; 
    fi
    if [ "$action" == "start" ] ; then
        local cmd="ssh -fnNT ${mode} ${local_port}:${remote_host}:${remote_port} ${host}"
        [ "$mode" == "-R" ] && local_port=$remote_port
        if pgrep -f "$cmd" ; then
            echo "tunnel is already running to $host on local_port=${local_port} mode=$mode"
            return 0
        fi

        $cmd || return
        echo "tunnel to ${host} is running on local_port=${local_port} mode=$mode"
    elif [ "$action" == "stop" ] ; then
        local pid=$(pgrep -f "${local_port}:${remote_host}:${remote_port}")
        if [ "$pid" == "" ] ; then
            echo "there is no tunnel running ... nothing to stop"
        else
            kill -9 $pid
            echo "DONE!"
        fi
    elif [ "$action" == "list" ] ; then
        ps fax | grep "ssh -fnNT" | grep -v "grep"
    else
        echo "ssh_tunnel start|stop|list HOST LOCAL_PORT REMOTE_PORT REMOTE_HOST(default:127.0.0.1) MODE(-L default otherwise -R)" 
    fi
}

function _list_sorted_console(){
    {
        local i reali
        for i in $(ls /sys/class/tty/ | grep ttyUSB) ; do
            reali=$(realpath /sys/class/tty/$i)
            echo "$reali"
        done
     } | sort
}

_gbl_my_console_usage(){
    echo -e "usage to console: $COLOR_GREEN c CONSOLE_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN c set CONSOLE_ALIAS IP$COLOR_NONE\n\
usage to del: $COLOR_GREEN c del CONSOLE_ALIAS $COLOR_NONE\n\
usage to list: $COLOR_GREEN c $COLOR_NONE or $COLOR_GREEN c list$COLOR_NONE \n\
FYI: to exit Ctrl + a then k"
    v list -dt console
    i=0
    for c in  $(_list_sorted_console) ; do
        echo "$i -> $(basename $c) : $(dirname $(dirname $(dirname $c)))"
        i=$((i+1))
    done
}


_gbl_my_console(){
    case "$1" in
    "get")
        v get -t console "$2"
        return 0;
    ;;
    "del")
        shift
        v del -t console $@
        return 0
    ;;
    "set")
        local alias=$2
        local full_console=$3
        if [ -z "$alias" ] || [ -z "$full_console" ] ; then
            echo "wrong arguments!"
            _gbl_my_console_usage
            return 1
        fi
        # we need to convert the number to sys_class_path
        local dev_path="$full_console"
        local baudrate=115200

        local arr=(${full_console//@/ })
        if [ "${#arr[@]}" == "2" ] ; then
            dev_path=${arr[0]}
            baudrate=${arr[1]}
        fi
        local i=0
        local ip=
        for c in  $(_list_sorted_console) ; do
            if [ "$i" == "$dev_path" ] ; then
                ip="$(dirname $(dirname $(dirname $c)))"
                break
            fi
            i=$((i+1))
        done
        [ -z "$ip" ] && {
            echo -e "Could not find the console port # $dev_path \n\n"
            _gbl_my_console_usage
            return 1
        }

        echo "set console to sys_path: # $dev_path -> $ip "
        full_console="$ip@$baudrate"
        echo "set it to $alias = $full_console"
        v set -t console "$alias=$full_console"
        return 0;
    ;;
    "list")
        v list -dt console
        return 0
    ;;
    esac
    local alias="$1"

    [  -z "$alias" ] && {
        _gbl_my_console_usage
        return 0
    }

    local ip=$(v get -t console "$alias" )
    if [ "$ip" == "" ] ; then
        ip=()
        if [ ${#alias} -gt 1 ] ; then
            # we search for allias only when is more than 1 character
            ip=($(v list -t console -n | grep "$alias"))
        fi
        if [ ${#ip[@]} == 0 ] ; then
            if [ -n "$alias" ] ; then
                echo "choised console #$alias"
                i=0
               for c in  $(_list_sorted_console) ; do
                    if [ "$i" == "$alias" ] ; then
                        ip="$(dirname $(dirname $(dirname $c)))"
                        break
                    fi
                    i=$((i+1))
                done
            else
                echo -e "console is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN c set $alias DEV_PATH@BAUDRATE$COLOR_NONE'"
                return 1
            fi
        elif (( ${#ip[@]} > 1 )) ; then
            echo -e "console $alias is ambigues: (${ip[@]})"
            return 1
        else
            echo "$alias -> $ip"
            alias="$ip"
            ip=$(v get -t console "$ip" )
        fi
    fi
    echo "got $ip"

    if [ -z "$ip" ] ; then
        #wrong arguments
        return 1
    fi

    # let's extract baudrate from SYS_DEV_PATH@115200
    local dev_path="$ip"
    local baudrate=115200
    local arr=(${ip//@/ })
    if [ "${#arr[@]}" == "2" ] ; then
        dev_path=${arr[0]}
        baudrate=${arr[1]}
    fi
    # let's convert the sys_DEV_PATH to read dev_path
    local real_sys_path=$(_list_sorted_console | grep "$dev_path")
    if [ -z "$real_sys_path" ] ; then
        echo -e "requested sys_path does not exist: $dev_path\n\n"
        _gbl_my_console_usage
        return 1
    fi
    dev_path=/dev/$(basename $real_sys_path)

    log "Starting  screen console to $dev_path ($baudrate): to exit Ctrl + a then k"
    local log_dir=/var/log/serial_console/${alias}/
    sudo mkdir -p $log_dir
    local running_screens="$(sudo ps -fa | grep -i screen | grep -i "$dev_path")"
    sudo screen -L -Logfile $log_dir/`date '+%Y-%m-%d_%Hh_%Mm_%Ss'`.log "$dev_path" "$baudrate"

}
#gbl_Bash_Auto_Complete
_gbl_bac_console_alias(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    conns="$(v list -nt console | grep "$cur")"
    if [ "$COMP_CWORD" -gt 1 ] ; then
        case "$prev" in
            "get"|"set"|"del")
            ;;
            *)
                conns= ;
            ;;
        esac
    else
        conns="$conns $(echo -e "get\nset\ndel\nlist" | grep "$cur") "
    fi


    COMPREPLY=( $(compgen -W "$conns") )
} ;
if type complete >/dev/null 2>&1 ; then
    complete -r c _gbl_bac_console_alias >/dev/null 2>&1; #firts remove old s autocomplete
    complete -F _gbl_bac_console_alias c
    alias c="_gbl_my_console"
fi
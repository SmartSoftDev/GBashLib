export G_BASH_LIB=$(dirname "${BASH_SOURCE[0]}")

. $(gbl ip)
. $(gbl log)
eval "$(r _print_autocomplete r)"
eval "$(d _print_autocomplete d)"

# 'j' jump Shortcut
_gbl_my_jump(){

    case "$1" in
    "get")
        v get -t path "$2"
        return 0;
    ;;
    "set")
        local p="$3"
        [[ "$3" == "." ]] && p=$(pwd)
        v set -t path "$2=$p"
        return 0;
    ;;
    "del")
        shift
        v del -t path $@
        return 0
    ;;
    "list")
        v list -dt path | column -t -n
        return 0
    ;;
    esac

    [[  -z "$1" ]] && {
        echo -e "usage to jump: $COLOR_GREEN j J_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN j set J_ALIAS PATH$COLOR_NONE\n\
usage to del: $COLOR_GREEN j del J_ALIAS $COLOR_NONE\n\
usage to list: $COLOR_GREEN j$COLOR_NONE or $COLOR_GREEN j list$COLOR_NONE "
        v list -dt path | column -t -n
        return 0
    }
    local location
    location=$( v get -t path "$1" )
    [[ "$location" == "" ]] && {
        location=($(v list -t path -n  | grep "$1"))
        if [[ ${#location[@]} == 0 ]] ; then
            echo -e "location is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN j set $1 PATH$COLOR_NONE'"
            return 1
    elif [ ${#location[@]} -gt 1 ] ; then
            echo -e "location $1 is ambigues: (${location[@]})"
            return 1
        else
            echo "$1 -> $location"
            location=$(v get -t path $location )
        fi
    }
    echo -e "\tjump to $COLOR_GREEN $location $COLOR_NONE"
    cd "$location"
}

_gbl_bac_jump_alias(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    conns="$(v list -nt path | grep "$cur")"
    if [ "$COMP_CWORD" -gt 1 ] ; then
        case "$prev" in
            "get"|"set")
            ;;
            *)
                conns= ;
            ;;
        esac
    else
        conns="$conns $(echo -e "get\nset\nlist" | grep "$cur") "
    fi


    COMPREPLY=( $(compgen -W "$conns") )
} ;
complete -r j _gbl_bac_jump_alias >/dev/null 2>&1; #firts remove old j autocomplete
complete -F _gbl_bac_jump_alias j

alias j="_gbl_my_jump"

# 's' ssh shortcut !
_gbl_my_ssh_usage(){
    echo -e "usage to ssh: $COLOR_GREEN s SSH_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN s set SSH_ALIAS IP$COLOR_NONE\n\
usage to del: $COLOR_GREEN s del SSH_ALIAS $COLOR_NONE\n\
usage to list: $COLOR_GREEN s$COLOR_NONE or $COLOR_GREEN s list$COLOR_NONE "

    v list -dt ssh | column -t -n
}


_gbl_my_ssh(){
    local isSCP=0
    case "$1" in
    "get")
        v get -t ssh $2
        return 0;
    ;;
    "del")
        shift
        v del -t ssh $@
        return 0
    ;;
    "set")
        local alias=$2
        local ip=$3
        if [ -z "$alias" ] || [ -z "$ip" ] ; then
            echo "wrong arguments!"
            _gbl_my_ssh_usage
            return 1
        fi
        echo "ip: $ip"
        # we must save the format user@ip
        local arr=(${ip//@/ })
        local user="root"
        local port=22
        parse_user_ip_port $ip

        ip=$_IP_ADDR
        [ "$_IP_PORT" != "" ] && port=$_IP_PORT
        [ "$_IP_USER" != "" ] && user=$_IP_USER


        tpl -i "$G_BASH_LIB/tpls/ssh_host.tpl" -r -I "_$alias" -o "$HOME/.ssh/config" -v "ALIAS=$alias" "IP=$ip" "USER=$user" "PORT=$port"
        #FIXME-SSD: when TPL will support permission mode remove this one
        chmod go-w $HOME/.ssh/config
        local save_ip=
        v set -t ssh "$alias=$user@$ip:$port"

        ssh-copy-id -p "$port" "$user@$ip" || {
            echo "could not copy ssh-id! FAIL!"
        }
        return 0;
    ;;
    "list")
        v list -dt ssh | column -t -n
        return 0
    ;;
    esac
    local alias="$1"
    local remote_src=
    local local_dst=

    [  -z "$alias" ] && {
        _gbl_my_ssh_usage
        return 0
    }

    local ip=$(v get -t ssh "$alias" )
    [ "$ip" == "" ] && {
        ip=($(v list -t ssh -n | grep "$alias"))
        if [ ${#ip[@]} == 0 ] ; then
            echo -e "shh is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN s set $alias IP$COLOR_NONE'"
            return 1
    elif (( ${#ip[@]} > 1 )) ; then
            echo -e "ip $alias is ambigues: (${ip[@]})"
            return 1
        else
            echo "$alias -> $ip"
            alias="$ip"
            ip=$(v get -t ssh "$ip" )
        fi
    }
    parse_user_ip_port "$ip"

    ip_txt="$_IP_USER@$_IP_ADDR"
    [ "$_IP_PORT" != "22" ] && ip_txt="-p $_IP_PORT $ip_txt"

    echo -e "\t $COLOR_GREEN ssh $ip_txt $COLOR_NONE $txt_port"
    ssh $alias
}
#gbl_Bash_Auto_Complete
_gbl_bac_ssh_alias(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    conns="$(v list -nt ssh | grep "$cur")"
    if [ "$COMP_CWORD" -gt 1 ] ; then
        case "$prev" in
            "get"|"add"|"update")
            ;;
            *)
                conns= ;
            ;;
        esac
    else
        conns="$conns $(echo -e "get\nadd\nupdate\nlist" | grep "$cur") "
    fi


    COMPREPLY=( $(compgen -W "$conns") )
} ;
complete -r s _gbl_bac_ssh_alias >/dev/null 2>&1; #firts remove old s autocomplete
complete -F _gbl_bac_ssh_alias s
alias s="_gbl_my_ssh"

#generate autoComplete
_gbl_autoComplete(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    local bin=${COMP_WORDS[0]}
    #echo "${COMP_WORDS[@]}"
    #echo "$COMP_KEY"
    #echo "$COMP_LINE"
    #echo $COMP_CWORD
    COMPREPLY=( $(compgen -W "$(autoComplete _get $COMP_CWORD ${COMP_WORDS[@]} )") )
}
ac_list=$(autoComplete _list)
for ac in ${ac_list[@]} ; do
    complete -r $ac _gbl_autoComplete >/dev/null 2>&1; #firts remove old j autocomplete
    complete -F _gbl_autoComplete $ac
done

#gbl load libraries
function gbl_load(){
    local path=$(gbl $1)
    if [ "$path" != "" ] ; then
        source $path
        echo "Load: $path"
    fi
}

function sd_usage(){
    echo "systed (sd) command usage:"
    echo "Commands:"
    echo -e "\tr    - restart"
    echo -e "\ts    - start"
    echo -e "\tS    - stop"
    echo -e "\tl    - logs (at the end)"
    echo -e "\tL    - logs (follow)"
    echo -e "\nServices:"
    for s in $(v list -t systemd -n)
    do
        echo -e "\t$s    - $(v get -t systemd $s)"
    done
}
function sd(){
    local cmd="$1"
    local run=""
    case $cmd in
        "r")
            run="sudo systemctl restart"
        ;;
        "s")
            run="sudo systemctl start"
        ;;
        "S")
            run="sudo systemctl stop"
        ;;
        "l")
            run="journalctl -eu"
        ;;
        "L")
            run="journalctl -feu"
        ;;
        *)
            sd_usage
            return
        ;;
    esac
    local service=""
    for s in $(v get -t systemd -s "$2") ; do
        if [ "$service" != "" ] ; then
            echo "Ambiguous service for '$2' :"
            for s in $(v get -t systemd -s "$2") ; do
                echo -e "\t$2 -> $s"
            done
            return
        fi
        service="$s"
    done
    echo "$run $service"
    $run "$service"
}


# 's' ssh shortcut !

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
usage to list: $COLOR_GREEN c $COLOR_NONE or $COLOR_GREEN c list$COLOR_NONE "

    v list -dt console | column -t -n
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
        v list -dt console | column -t -n
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
    sudo screen "$dev_path" "$baudrate"

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
complete -r c _gbl_bac_console_alias >/dev/null 2>&1; #firts remove old s autocomplete
complete -F _gbl_bac_console_alias c
alias c="_gbl_my_console"
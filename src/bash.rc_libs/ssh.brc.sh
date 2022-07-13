
# 's' ssh shortcut !

. $(gbl ip)
. $(gbl log)

_gbl_my_ssh_usage(){
    echo -e "usage to ssh: $COLOR_GREEN s SSH_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN s set SSH_ALIAS IP$COLOR_NONE\n\
usage to del: $COLOR_GREEN s del SSH_ALIAS $COLOR_NONE\n\
usage to list: $COLOR_GREEN s$COLOR_NONE or $COLOR_GREEN s list$COLOR_NONE "

    v list -dt ssh
}


_gbl_my_ssh(){
    local isSCP=0
    case "$1" in
    "del")
        shift
        v del -t ssh $@
        return 0
    ;;
    "set")
        # let's parse the options
        local ProxyJump=""
        while [[ "$2" == --* ]] ; do
            case "$2" in
            "--ProxyJump")
                ProxyJump="ProxyJump=$3"
                shift
                shift
                ;;
            *)
                fatal "Unexpeted $2 option";
                ;;
            esac
        done
        local alias=$2
        local ip=$3
        if [ -z "$alias" ] || [ -z "$ip" ] ; then
            echo "wrong arguments!"
            _gbl_my_ssh_usage
            return 1
        fi
        echo "alias: $alias ip: $ip"
        # we must save the format user@ip
        local user="root"
        local port=22
        parse_user_ip_port "$ip"

        ip=$_IP_ADDR
        [ "$_IP_PORT" != "" ] && port=$_IP_PORT
        [ "$_IP_USER" != "" ] && user=$_IP_USER


        tpl -i "$G_BASH_LIB/tpls/ssh_host.tpl" -r -I "_$alias" -o "$HOME/.ssh/config" \
            -v "ALIAS=$alias" "IP=$ip" "USER=$user" "PORT=$port" "VALUE_PJ=$ProxyJump"
        #FIXME-SSD: when TPL will support permission mode remove this one
        chmod go-w $HOME/.ssh/config
        local save_ip="$alias=$user@$ip:$port"
        [ "$ProxyJump" != "" ] && save_ip="$save_ip $ProxyJump"
        v set -t ssh "$save_ip"

        ssh-copy-id $alias || {
            echo "could not copy ssh-id! FAIL!"
        }
        return 0;
    ;;
    "list")
        v list -dt ssh
        return 0
    ;;
    esac
    # let's parse the options
    local opt_wait=""
    while [[ "$1" == --* ]] ; do
        case "$1" in
        "--wait")
            opt_wait="yes"
            shift
            ;;
        *)
            fatal "Unexpeted $1 option";
            ;;
        esac
    done
    local alias="$1"
    [  -z "$alias" ] && {
        _gbl_my_ssh_usage
        return 0
    }

    local ip=$(v get -t ssh "$alias")
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
    ip=($ip)
    parse_user_ip_port "$ip"

    ip_txt="$_IP_USER@$_IP_ADDR"
    [ "$_IP_PORT" != "22" ] && ip_txt="-p $_IP_PORT $ip_txt"
    unset ip[0]
    for ssh_option in ${ip[@]} ; do
        ip_txt="-o$ssh_option $ip_txt"
    done
    echo -e "\t $COLOR_GREEN ssh $ip_txt $COLOR_NONE"
    [ "$opt_wait" == "yes" ] && {
        echo -e "\t  wait for SSH ..."
        SECONDS=0

        while true ; do
            ssh -o ConnectTimeout=2 -t $1 "true" > /dev/null 2>&1  || {
                echo -n " ."
                continue
            }
            echo -e "$COLOR_GREEN ssh is up! $COLOR_NONE in $SECONDS sec"
            break
        done
    }

    ssh $alias
}
#gbl_Bash_Auto_Complete
_gbl_bac_ssh_alias(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    if [ "$COMP_CWORD" -gt 1 ] ; then
        case "$prev" in
            "set")
                conns="$(echo -e "--ProxyJump\n" | grep "$cur") "
            ;;
            "del"|"list")
            ;;
            *)
                conns="$(v list -nt ssh -i -f "$cur")"
            ;;
        esac
    else
        if [ "${cur:0:1}" == "-" ] ; then
            conns="--wait"
        elif [ "${cur:0:2}" == "--" ] ; then
            for i in $(echo -e "wait\n" | grep "${cur:2}") ; do
                conns="$conns --$i"
            done
        else
            conns="$(v list -nt ssh -i -f "$cur")"
            conns="$conns $(echo -e "set\ndel\nlist\n--wait\n" | grep "$cur")"
        fi
    fi

    COMPREPLY=( $(compgen -W "$conns") )
} ;
if type complete >/dev/null 2>&1 ; then
    complete -r s _gbl_bac_ssh_alias >/dev/null 2>&1; #firts remove old s autocomplete
    complete -F _gbl_bac_ssh_alias s
fi
alias s="_gbl_my_ssh"
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
if type complete >/dev/null 2>&1 ; then
    complete -r s _gbl_bac_ssh_alias >/dev/null 2>&1; #firts remove old s autocomplete
    complete -F _gbl_bac_ssh_alias s
fi
alias s="_gbl_my_ssh"
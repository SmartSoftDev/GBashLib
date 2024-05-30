
# 's' ssh shortcut !

. $(gbl ip)
. $(gbl log)
. $(gbl animation)

_gbl_my_ssh_usage(){
    echo -e "usage to ssh: $COLOR_GREEN s SSH_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN s set SSH_ALIAS IP$COLOR_NONE\n\
usage to set: $COLOR_GREEN s set --ProxyJump proxyHostAlias some_user@some_host SSH_ALIAS IP$COLOR_NONE\n\
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
        tpl -i "$G_BASH_LIB/tpls/ssh_host.tpl" -I "_$1" -d -p urw -o "$HOME/.ssh/config"
        return 0
    ;;
    "set")
        # let's parse the options
        local ProxyJump=""
        local template_file="$G_BASH_LIB/tpls/ssh_host.tpl"
        while [[ "$2" == -* ]] ; do
            case "$2" in
            "--ProxyJump")
                ProxyJump="ProxyJump=$3"
                shift
                shift
                ;;
            --template)
                template_file="$3"
                shift
                shift
                ;;
            *)
                err "Unexpected $2 option";
                return 1
                ;;
            esac
        done
        # let's preprocess the template file value
        # if template file is absolute path then use it, else is a file name in GBL tpls directory
        case $template_file in 
            /*) 
                true
                ;; 
            *)
                template_file=$G_BASH_LIB/tpls/$template_file
                ;; 
        esac
        
        [ ! -f $template_file ] && {
            err "Template file $template_file NOT FOUND"
            return 1
        }

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


        tpl -i $template_file -r -I "_$alias" -o "$HOME/.ssh/config" -p urw \
            -v "ALIAS=$alias" "IP=$ip" "USER=$user" "PORT=$port" "VALUE_PROXY_JUMP=$ProxyJump"
        local save_ip="$alias=$user@$ip:$port"
        [ "$ProxyJump" != "" ] && save_ip="$save_ip $ProxyJump"
        [ "$template_file" != "$G_BASH_LIB/tpls/ssh_host.tpl" ] && save_ip="$save_ip ${template_file#$G_BASH_LIB/tpls/}"
        
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
    while [[ "$1" == -* ]] ; do
        case "$1" in
        "--wait")
            opt_wait="yes"
            shift
            ;;
        "-w")
            opt_wait="yes"
            shift
            ;;
        *)
            err "Unexpected $1 option";
            return 1
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
            echo -e "ip $alias is ambiguous: (${ip[@]})"
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
        if ! echo "$ssh_option" | grep -q ".tpl"; then
            ip_txt="-o$ssh_option $ip_txt"
        fi
    done
    echo -e "\t $COLOR_GREEN ssh $ip_txt $COLOR_NONE"
    local ssh_conn
    [ "$opt_wait" == "yes" ] && {
        SECONDS=0
        while true ; do
            # try to open ssh connection for 2 seconds then close it
            ssh_conn="$(ssh -o ConnectTimeout=2 $1 echo ok 2>&1)"
            if [ "$ssh_conn" == "ok" ]; then
                echo -e "$COLOR_GREEN ssh is up! $COLOR_NONE in $SECONDS sec"
                break
            else
                loading_dots 10 "\t  wait for SSH "
            fi
        done
    }

    ssh $alias
}
#gbl_Bash_Auto_Complete
_gbl_bac_ssh_alias(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    local first=${COMP_WORDS[1]}
    case "$first" in
        "set")
            # grep -e "--" works for speacial characters
            conns="$(echo -e "--template\n--ProxyJump\n" | grep -i -e "$cur")"
        ;;
        "del"|"list")
        ;;
        *)
            conns="$(v list -nt ssh -i -f "$cur")"
            conns="$conns $(echo -e "set\ndel\nlist\n--wait\n" | grep -i -e "$cur")"
        ;;
    esac

    COMPREPLY=( $(compgen -W "$conns") )
} ;

if type complete > /dev/null 2>&1 ; then
    complete -r s _gbl_bac_ssh_alias > /dev/null 2>&1; #firts remove old s autocomplete
    complete -F _gbl_bac_ssh_alias s
fi

alias s="_gbl_my_ssh"
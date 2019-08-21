export G_BASH_LIB=$(dirname ${BASH_SOURCE[0]})

. $(gbl ip)
. $(gbl log)
eval "$(r _print_autocomplete r)"
eval "$(d _print_autocomplete d)"

# 'j' jump Shortcut
_gbl_my_jump(){

	case "$1" in
	"get")
		v get -t path $2
		return 0;
	;;
	"set")
		local p=$3
		[[ "$3" == "." ]] && p=$(pwd)
		v set -t path "$2=$p"
		return 0;
	;;
	"del")
	    v del -t path $2
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
	local location=$(v get -t path $1 )
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
		
	#trebuie de parsat ip care are forma user@ip
		local arr=(${ip//@/ })
		local user="root"
		local port=22
		parse_user_ip_port $ip
		
		ip=$_IP_ADDR
		[ "$_IP_PORT" != "" ] && port=$_IP_PORT
		[ "$_IP_USER" != "" ] && user=$_IP_USER
		
		
		tpl -i $G_BASH_LIB/tpls/ssh_host.tpl -r -I "_$alias" -o "$HOME/.ssh/config" -v ALIAS=$alias IP=$ip USER=$user PORT=$port
		local save_ip=
		v set -t ssh "$alias=$user@$ip:$port"
		
		ssh-copy-id -p $port $user@$ip || {
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
	
	local ip=$(v get -t ssh $alias )
	[ "$ip" == "" ] && {
		ip=($(v list -t ssh -n  | grep "$alias"))
		if [ ${#ip[@]} == 0 ] ; then 
			echo -e "shh is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN s set $alias IP$COLOR_NONE'"
			return 1
	elif [ ${#ip[@]} -gt 1 ] ; then
			echo -e "ip $alias is ambigues: (${ip[@]})"
			return 1
		else
			echo "$alias -> $ip"
			alias="$ip"
			ip=$(v get -t ssh $ip )
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
complete -r s _gbl_bac_ssh_alias >/dev/null 2>&1; #firts remove old j autocomplete 
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

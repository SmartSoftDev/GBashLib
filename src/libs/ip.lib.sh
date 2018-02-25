# . $G_BASH_LIB/libs/ip.lib.bsh

function parse_user_ip_port(){
	#trebuie de parsat ip care are forma user@ip:port
	local ip=$1
	local user=""
	local port=""
	if [ -z "$ip" ] ; then
		#wrong argumens
		return 1 
	fi
	
	local arr=(${ip//@/ })
	if [ "${#arr[@]}" == "2" ] ; then
		user=${arr[0]}
		ip=${arr[1]}
	fi
	arr=(${ip//:/ })
	if [ "${#arr[@]}" == "2" ] ; then
		port=${arr[1]}
		ip=${arr[0]}
	fi
	
	_IP_ADDR=$ip
	_IP_USER=$user
	_IP_PORT=$port
}

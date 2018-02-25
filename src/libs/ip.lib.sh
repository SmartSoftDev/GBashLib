# . $G_BASH_LIB/libs/ip.lib.bsh

function parse_user_ip_port(){
	#This functions extracts  user@ip:port/URI
	local ip=$1
	local user=""
	local port=""
	local uri=""
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
	arr=(${port//\// })
	if [ "${#arr[@]}" == "2" ] ; then
		uri=${arr[1]}
		port=${arr[0]}
	fi
	
	_IP_ADDR=$ip
	_IP_USER=$user
	_IP_PORT=$port
	_IP_URI=$uri
}


function get_input_endless(){
	local txt="$1"
	local default="$2"
	while true 
	do
		echo -ne "$txt"
		if [ -z "$default" ] ; then
			echo ""
		else
			echo "(default: $default)"
		fi
		read READ_VAR
		[ -z "$READ_VAR" ] && [ -z "$default" ] || break
	done
	[ -z "$READ_VAR" ] && READ_VAR=$default
}

function get_input_endless_yes_no(){
	local txt="$1"
	local default="$2"
	while true 
	do
		echo -e "$txt. y/n? (default: $default)"
		read READ_VAR
		[ -z "$READ_VAR" ] && [ -z "$default" ] || break
		[[ "$READ_VAR" =~ y|n ]] && break
	done
	[ -z "$READ_VAR" ] && READ_VAR="$default"
}

function get_input_yes_no(){
	local txt="$1"
	local default="$2"
	while true 
	do
		echo -e "$txt. y/n? (default: $default)"
		read READ_VAR
		[ -z "$READ_VAR" ] && [ -z "$default" ] || break
		[[ "$READ_VAR" =~ y|n ]] && break
	done
	[ -z "$READ_VAR" ] && READ_VAR="$default"
}

function get_input_yes_no_exit(){
	local txt="$1"
	local default="$2"
	
	get_input_yes_no "$txt" "$default"
	
	[ "$READ_VAR" == "n" ] && {
		echo "bye bye !"
		exit 0
	}
}
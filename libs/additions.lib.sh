gblcmd_descr_zfind_bl_scripts=('Will search for scripts with extension *.bl.sh and add them to autocomplete list' 'ABS_PATH')
gblcmd_zfind_bl_scripts(){
	[ -z "$1" ] && gbl_fatal "the ABS_PATH shall be provided"
	[ -d "$1" ] || gbl_fatal "the ABS_PATH shall be a directory"
	_create_variable_storage
	
	find "$1/" -name "*.bl.sh" 2>/dev/null > $VAR_STORAGE_DIR/.bl_script_list
	echo "found this bl scripts:"
	cat  $VAR_STORAGE_DIR/.bl_script_list
}


#VAR_STORAGE_DIR is used but not set now. Because maybe the script want to change is 
_create_variable_storage(){
	[ -z "$VAR_STORAGE_DIR" ] && VAR_STORAGE_DIR=$HOME/.gbl/
	gbl_test_dirs $VAR_STORAGE_DIR || { mkdir -p $VAR_STORAGE_DIR || ady_fatal "could not create persistent variable dir $VAR_STORAGE_DIR"; }
}

_zset_autocomplete(){
	_create_variable_storage
	for i in $(ls $VAR_STORAGE_DIR) ; do
		echo "$i" 
	done
		
}

gblcmdautocomp_zset_1=_zset_autocomplete
gblcmd_descr_zset=('set variable_name to persistent $HOME/.gbl/variable_name. args: vset NAME VALUE' 'VAR_NAME VAR_VALUE' )
gblcmd_zset(){
	_create_variable_storage
	[ -z "$1" ] && gbl_fatal "the vset NAME shall be provided"
	local var_name=$1
	shift
	gbl_variable set $var_name $@
}

gbl_descr_variable=('save/read variable from persistent location $HOME/.gbl/variable_name; ' 'set VAR_NAME SET_VALUE / get VAR_NAME [GET_DEFAULT_VALUE]')
gbl_variable(){
	_create_variable_storage
	[[ "$1" != "set" && "$1" != "get" ]] && gbl_fatal "gbl_variable: bad command! can be only set/get"
	[ -z "$2" ] && gbl_fatal "gbl_variable: variable name canot be empty"
	
	# if variable with $2 name exists we just return because we don`t want to change it and it is always available.
	[ ! -z "${!2}" ] && return 0
	local cmd=$1
	local name=$2
	shift 
	shift
	#shift
	local value=( $@ )
	local is_multi_value=""
	[[ $# > 1 ]] &&  is_multi_value="true";
	#implement with set NAME=VALUE
	
	if [[ $name == *=* ]] 
	then
		local arr=( $( echo "$name" | tr '=' ' ' ) )
		name="${arr[0]}"
		if [ -z "$is_multi_value" ] 
		then 
			value="${arr[1]}"
		else
			value=( "${arr[1]}" ${value[@]} )
		fi
	fi
	
	local fname=$VAR_STORAGE_DIR/$name 
	if [ "$cmd" == "get" ] ; then 
		if [ -f $fname ] ; then
			. $fname
		else
			if [ -z "$is_multi_value" ] 
			then
				eval $name'="'$value'"'
			else
				eval $name'=( '${value[@]}' )'
			fi
		fi
	else
		if [ -z "$value" ] ; then
			rm $fname
		else 
			if [ -z "$is_multi_value" ] 
			then 
				echo $name'="'$value'"' > $fname
			else
				echo $name'=( '${value[@]}' )' > $fname
			fi
		fi			
	fi
}
GBL_VARIABLE_LIST=""
gbl_list_variables(){
	_create_variable_storage
	GBL_VARIABLE_LIST=( $(ls $VAR_STORAGE_DIR) )
}

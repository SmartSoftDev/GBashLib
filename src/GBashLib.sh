#gbl_usage_function
_NAME=$(basename $0)

_gbl_usage(){
	cat <<EOM
Usage:
$0 [OPTIONS] command1 arg1 arg2 -- command2 arg1 arg2 -- ... 
EOM
	echo "";
	echo "OPTIONS: getopt='$G_ARGS'"
	local GETOPT_ARGS_INDEX=`echo $G_ARGS | sed 's/[:]*//g'`
	local OPTIONS=($(echo $GETOPT_ARGS_INDEX | fold -w1))
	for (( i=0; i<${#OPTIONS[@]}; i++ ));
	do
		local var_name=G_ARGS_DESCR_${OPTIONS[$i]}
		echo -e "\t-${OPTIONS[$i]} : ${!var_name}"
		
	done
	echo "";
	echo "COMMANDS:"
	local G_COMMANDS=( $(compgen -A function |grep gblcmd_ | cut -c8- | sort ) )
	local cmds_text='';
	for (( i=0; i<${#G_COMMANDS[@]}; i++ ));
	do 
		#echo -e "\t${G_COMMANDS[$i]} : ${G_COMMANDS_DESCR[$i]}"
		local var_name=gblcmd_descr_${G_COMMANDS[$i]}
		local var_name_args=gblcmd_descr_${G_COMMANDS[$i]}[1]
		local cmd_descr=$(echo "${!var_name}" | tr " " "!+!")
		local cmd_name=$(echo "${G_COMMANDS[$i]}" | tr " " "!+!")
		local cmd_args=${!var_name_args}
		if [ ! -z "$cmd_args" ] ; then
			cmd_args=$(echo "$cmd_args" | tr " " "!+!" )
		else
			cmd_args='-'
		fi
		cmds_text+="\t  ${cmd_name} ${cmd_args} $cmd_descr\n"
	done
	echo -e $cmds_text | column -t -n | tr "!+!" " "
	
	echo "";
	echo "$G_USAGE_SFX"
}

#gbl_loging
gbl_descr_fatal='print a fatal error and then exit 1'
gbl_fatal(){
	echo -e "FATAL:\t $@\n\n---try help command for more information:\$ $0 help\n" 1>&2
	exit 1;
}
gbl_descr_log='print a standard log message (like echo -e)'
gbl_log(){
	echo -e "$@"
}

gbl_descr_err='print a ERROR message'
gbl_err(){
	echo -e "ERROR:\t $@" 1>&2
}

#G special commands (build-in commands)

gblcmd_descr_zhelp='print help information (this screen)'
gblcmd_zhelp(){
	_gbl_usage
	echo -e "\nAUTOCOMPLETE: \teval \"\$( $0 _print_autocomplete )\" \n \t\teval \"\$( $0 _print_autocomplete alias_name)\"" 
	echo "";
	echo "G FUNCTIONS:"
	local G_FUNCTIONS=( $(compgen -A function |grep -e "^gbl_" | cut -c5-) )
	
	for (( i=0; i<${#G_FUNCTIONS[@]}; i++ ));
	do 
		local var_name=gbl_descr_${G_FUNCTIONS[$i]}
		echo -e "\tgbl_${G_FUNCTIONS[$i]} : ${!var_name}"
	done
	
	#compgen -A function | grep -e "^gbl_"
	echo ""
}

#G framework

#G AUTOCOMPLETE logic
gprint_autocomplete_bash_code(){
	pushd `dirname $0` > /dev/null
	SCRIPTPATH=`pwd`/`basename $0`
	popd > /dev/null
	
	AUTOCOMPLETENAME=$_NAME
	[ ! -z $2 ] && AUTOCOMPLETENAME=$2
	echo "_gbl_bac_${_NAME}(){"
	echo 'local cur=${COMP_WORDS[COMP_CWORD]}'
	echo 'local prev=${COMP_WORDS[COMP_CWORD-1]}'
	echo 'COMPREPLY=($('$SCRIPTPATH' _print_autocomplete_result $COMP_CWORD ${COMP_WORDS[@]}))'
	echo "} ; complete -r ./$AUTOCOMPLETENAME $AUTOCOMPLETENAME >/dev/null 2>&1; complete -F _gbl_bac_$_NAME $AUTOCOMPLETENAME"
}
_ALLCMDS=($(compgen -A function |grep gblcmd_ | cut -c8- | sort) --)

if [ "$1" == "_print_autocomplete_result" ] ; then
	shift
	CWORD=$1
	shift
	shift
	REZ=(${_ALLCMDS[@]})
	FILETER=""
	UNKNOWN="no"
	if [ $# == "1" ] && [ $# == $CWORD ] ; then
		FILTER="$1"
	else
		#find if there is an autocompletion function for this command
		arr=($@)
		j=0
		cmd=""
		for (( i= 0; i < $# ; i++ )) ; do
			[ ${arr[$i]} == "--" ] && {
				let j=$i+1
				cmd=""
			}
			[ $j == $i ] && cmd=${arr[$i]}
		done
		let z=i-1
		if [ $z == $j ] && [ $# == $CWORD ] ;then
			FILTER="$cmd" 
		else
			if [ "x$cmd" != "x" ]; then
				let x=$i-$j
				if [ $# == $CWORD ] ; then 
					let x--
					#we need to set filter
					let z=$#-1
					FILTER=${arr[$z]}
				fi
				var_name="gblcmdautocomp_${cmd}_$x"
				var_value=${!var_name}
				if [ "x$var_value" != "x" ] ; then
					REZ=($(eval $var_value ))
				else
					var_name="gblcmdautocomp_${cmd}_0" #handler for all arguments
					var_value=${!var_name}
					if [ "x$var_value" != "x" ] ; then
						REZ=($(eval $var_value $x ))
					else
						UNKNOWN="yes"
					fi
				fi
			fi
		fi
	fi
	if [ "x$UNKNOWN" == "xyes" ] ; then
		REZ=($(ls))
	fi
	
	if [ "x$FILTER" != "x" ] ; then
		if [ "x$UNKNOWN" == "xyes" ] ; then
			REZ=($(ls $(dirname $FILTER)))
			FILTER=${FILTER##*/}
		fi
		
		for i in ${REZ[@]} ; do
			[[ "$i" =~ "$FILTER" ]] && echo $i  
		done
	else
		echo "${REZ[@]}"
	fi
	exit 0
fi
if [ "$1" == "_print_autocomplete" ] ; then
	gprint_autocomplete_bash_code $@
	exit 0
fi


#G arguments parsing
MAX_INDEX=0
while getopts $G_ARGS flag >/dev/null 2>&1 
do
	if [ "$flag" == "?" ] ; then gbl_err "unknown option!\n"; _gbl_usage ; exit 0 ; fi
	declare "G_ARG_$flag=$OPTARG"
	eval 'if [ -z "$G_ARG_'$flag'" ] ; then G_ARG_'$flag'=true ; fi'
	MAX_INDEX=$OPTIND
done
for i in $(seq 2 $MAX_INDEX) ; do
	shift 
done

type gbl_parse_args >/dev/null 2>&1 && gbl_parse_args

#G run commands logic


CMD_RUN_COUNT=

while [ $# -gt 0 ]
do
	CMD=$1
	if [ -z "$CMD" ] ; then
		break
	fi
	shift
	CMD_ARGS=()
	i=0
	
	while [ $# -gt 0 ]
	do
		if [ -z $1 ] ; then break; fi
		if [ "$1" == "--" ] ; then shift; break; fi
		((i++))
		CMD_ARGS[i]=$1
		shift
	done
	type gblcmd_$CMD >/dev/null 2>&1 || {
		#check for prefix commands
		all_cmds=( ${_ALLCMDS[@]} )
		detect=( )
		for i in ${all_cmds[@]} ; do if [[ "$i" =~ "$CMD" ]] ; then detect=( ${detect[@]} $i) ; fi ; done ;
		if [ ${#detect[@]} -gt 0 ] ; then
			if [ ${#detect[@]} -gt 1 ] ; then
				gbl_fatal "ambigous command '$CMD' -> ( ${detect[@]} )"
			else
				gbl_log "$CMD -> $detect"
				CMD=$detect
			fi
		else
			gbl_err "command '$CMD' is not found!\n"; _gbl_usage ; exit 127 ;
		fi
		}
	#echo -e "\tcommand: '$CMD' with args '${CMD_ARGS[@]}'"
	gblcmd_$CMD ${CMD_ARGS[@]}
	CMD_RUN_COUNT=1
done

if [ "$CMD_RUN_COUNT" != "1" ] ; then 
	#gbl_fatal "No command specified!"
	_gbl_usage
fi

exit 0;
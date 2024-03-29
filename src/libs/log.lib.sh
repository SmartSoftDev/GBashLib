
#. $G_BASH_LIB/libs/log.lib.bsh
COLOR_NONE='\e[0m' # No Color
COLOR_WHITE='\e[1;37m'
COLOR_BLACK='\e[0;30m'
COLOR_BLUE='\e[0;34m'
COLOR_LIGHT_BLUE='\e[1;34m'
COLOR_GREEN='\e[0;32m'
COLOR_LIGHT_GREEN='\e[1;32m'
COLOR_CYAN='\e[0;36m'
COLOR_LIGHT_CYAN='\e[1;36m'
COLOR_RED='\e[0;31m'
COLOR_LIGHT_RED='\e[1;31m'
COLOR_PURPLE='\e[0;35m'
COLOR_LIGHT_PURPLE='\e[1;35m'
COLOR_BROWN='\e[0;33m'
COLOR_YELLOW='\e[1;33m'
COLOR_GRAY='\e[0;30m'
COLOR_LIGHT_GRAY='\e[0;37m'

fatal(){
	echo -e "$COLOR_RED\nFATAL:\t $@\n\n$COLOR_NONE" 1>&2
	exit 1;
}

log(){
	echo -e "$@"
}

err(){
	echo -e "ERROR:\t $@" 1>&2
}

wrn(){
	echo -e "WARN:\t $@"
}
log_error(){
	echo -e "$COLOR_RED ERROR: $@ $COLOR_NONE "
}

log_warning(){
	echo -e "$COLOR_YELLOW WARNING: $COLOR_NONE $@"
}
log_success(){
	echo -e "$COLOR_GREEN $@ $COLOR_NONE"
}

function __error_report(){
	echo "ERROR at $1:$2"
}

function error_trap(){
	if [ "$1" == "off" ] ; then
		set +o errtrace
		return
	fi
	set -o errtrace
	trap '__error_report $BASH_SOURCE $LINENO' ERR
}

function check_var_empty(){
    local var_name="$1"
    local var_value="$2"
    [ "$var_value" == "" ] && fatal "$var_name is EMPTY!"
}
. $G_BASH_LIB/libs/input.lib.bsh

function add_j(){
	v set -t path $1
	sudo PYTHONPATH=$PYTHONPATH HOME=/root/ v set -t path $1
}
function add_git(){
	v set -t git $1
}
function add_svn(){
	v set -t svn $1
}


function fatal (){
	echo "!!! FATAL: $@"
	exit 1
}

function check_path(){
	local p=$1
	[ "$p" == "" ] && return 1
	ABS_PATH=$(readlink -e $p)
	[ -z "$ABS_PATH" ] && return 1
	[ ! -e "$ABS_PATH" ] && return 1
	return 0
}

function add_delayed_install(){
	v set -t delayed_install --append di="$1"
}

function get_delayed_install(){
	DELAYED_INSTALL=$(v get -t delayed_install di)
	v set -t delayed_install di
}
#!/bin/bash
export G_BASH_LIB=GBL_PATH

[ "$1" == "-H" ] && {
	HOME="$2"
	shift
	shift
}
DST=$HOME/d.bl.sh
# if d.bl.sh is a directory include all *.bl.sh files from there
if [ -d "$DST" ] ; then
	for i in "$DST"/*.bl.sh
	do
		if [ -f "$i" ] ; then
			source "$i"
		fi
	done
elif [ -f "$DST" ] ; then
	source "$DST"
else
	if [ "$1" == "_print_autocomplete" ] ; then
		#no autocomplete results
		exit 0
	fi
	echo -e "THERE IS NO R COMMANDS FOUND!\n"
fi

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; }
. "$G_BASH_LIB/GBashLib.sh"


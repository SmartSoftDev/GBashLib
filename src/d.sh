#!/bin/bash
export G_BASH_LIB=GBL_PATH
if [ "$1" != "_print_autocomplete" ] ; then
	if [ ! -f ./d.bl.sh ] ; then
		echo "there is no ./d.bl.sh to run in this directory"
		exit 1
	fi
	D_BL_SH_DIR=$(pwd)
	source ./d.bl.sh
fi
#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; }
. "$G_BASH_LIB/GBashLib.sh"

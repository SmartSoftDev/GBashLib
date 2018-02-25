#!/bin/bash
if [ "$1" != "_print_autocomplete" ] ; then
	if [ ! -f ./d.bl.sh ] ; then 
		if [ "$1" == "_print_autocomplete_result" ] ; then
			#no autocomplete results 
			exit 0
		fi
		echo "there is no ./d.bl.sh to run in this directory"
		exit 1
	fi
	source ./d.bl.sh
fi
#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; } 
. $G_BASH_LIB/GBashLib.sh

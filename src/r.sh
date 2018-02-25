#!/bin/bash
d_file=$HOME/d.bl.sh
if [ -f $d_file ] ; then
	source $d_file
fi

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; } 
. $G_BASH_LIB/GBashLib.sh


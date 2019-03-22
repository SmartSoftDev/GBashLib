#!/bin/bash
DST=$HOME/d.bl.sh
# if d.bl.sh is a directory ilclude all *.bl.sh files from there
if [ -d $DST ] ; then
	for i in $DST/*.bl.sh
	do
		if [ -f $i ] ; then
			source $i
		fi
	done
else
	if [ -f $DST ] ; then
		source $DST
	else 
	 echo -e "THERE ARE NO R COMMANDS FOUND!\n!!!\n!!!"
	fi
fi

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; } 
. $G_BASH_LIB/GBashLib.sh


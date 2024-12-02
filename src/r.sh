#!/bin/bash
# NOTE: src/tpls/gbl_bin.tpl.sh is sourcing this binary, where G_BASH_LIB is exported

[ "$1" == "-H" ] && {
	HOME="$2"
	shift
	shift
}
. $(gbl log)
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

gblcmd_d_lib_add(){
	local lib_name="$1"
    local lib_inc="$G_BASH_LIB/d_libs/d_${lib_name}.bl.sh"
	[ ! -f $lib_inc ] && fatal "'$lib_name' does not exist in $lib_inc"

	mkdir -p ~/d.bl.sh/
	ln -s $lib_inc ~/d.bl.sh/
    
}

gblcmd_d_lib_list(){
	ls -l $G_BASH_LIB/d_libs/
	for i in $(ls -l ~/d.bl.sh/ 2>/dev/null )
    do
        local lib_name=${i:2:-6}
        [ "$lib_name" != "" ] && echo $lib_name
    done
    echo "Available in d_libs:"
    for i in $(ls $G_BASH_LIB/d_libs/)
    do
        local lib_name=${i:2:-6}
        [ "$lib_name" != "" ] && echo -e "\t$lib_name"
    done
}

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; }
. "$G_BASH_LIB/GBashLib.sh"


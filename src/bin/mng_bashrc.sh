#!/bin/bash
export G_BASH_LIB=GBL_PATH

dest="$HOME/.bashrc"

. $(gbl log)

gblcmd_descr_add="Add bash.rc Library to the $dest of current user=$USER"
gblcmd_add(){
    local brc_lib="$1"
    local brc_inc="$G_BASH_LIB/bash.rc_libs/${brc_lib}.brc.sh"
    [ ! -f $brc_inc ] && fatal "'$brc_lib' does not exist in $G_BASH_LIB/bash.rc_libs/"

    echo "adding '$brc_lib' to $dest"
    tpl -i $G_BASH_LIB/tpls/bashrc.tpl -r -I "$brc_lib" -o $dest -v "BASHRC_INC=$G_BASH_LIB/bash.rc_libs/${brc_lib}.brc.sh"
}

gblcmd_remove(){
    local brc_lib="$1"

    echo "remove '$brc_lib' from $dest"
    tpl -i $G_BASH_LIB/tpls/bashrc.tpl -r -I "$brc_lib" -d -o $dest
}

gblcmd_list(){
    for i in $(cat $dest | grep "#G_BASH_LIB_bashrc.inc" | grep -v "_END")
    do
        local lib_name=${i:22}
        [ "$lib_name" != "" ] && echo $lib_name
    done
    echo "Available in GBashLib:"
    for i in $(ls $G_BASH_LIB/bash.rc_libs/)
    do
        local lib_name=${i:0:-7}
        [ "$lib_name" != "" ] && echo -e "\t$lib_name"
    done
}

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; }
. "$G_BASH_LIB/GBashLib.sh"

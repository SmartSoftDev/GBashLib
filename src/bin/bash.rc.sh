#!/bin/bash

dest="$HOME/.bashrc"

gblcmd_descr_add="Add bash.rc Library to the $dest of current user=$USER"
gblcmd_add(){
    local brc_lib="$1"
    echo "adding '$brc_lib' to $dest"
    tpl -i $G_BASH_LIB/tpls/bashrc.tpl -r -I "$brc_lib" -o $dest -v "BASHRC_INC=$G_BASH_LIB/bash.rc_libs/${brc_lib}.brc.sh"
}

gblcmd_remove(){
    local brc_lib="$1"

    echo "remove '$brc_lib' from $dest"
    tpl -i $G_BASH_LIB/tpls/bashrc.tpl -r -I "$brc_lib" -d -o $dest
}

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; }
. "$G_BASH_LIB/GBashLib.sh"

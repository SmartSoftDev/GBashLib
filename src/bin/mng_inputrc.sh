#!/bin/bash
export G_BASH_LIB=GBL_PATH

dest="$HOME/.inputrc"
lib_dir="inputrc_libs"

. $(gbl log)

gblcmd_descr_add="Add inputrc Library to the $dest of current user=$USER"
gblcmd_add(){
    local lib_name="$1"
    local lib_inc="$G_BASH_LIB/$lib_dir/${lib_name}.inputrc.cfg"
    [ ! -f $lib_inc ] && fatal "'$lib_name' does not exist in $G_BASH_LIB/${lib_dir}/"

    echo "adding '$lib_name' to $dest"
    tpl -i $G_BASH_LIB/tpls/inputrc_include.tpl -r -I "$lib_name" -o $dest -v "INCLUDE_PATH=$lib_inc"
}

gblcmd_remove(){
    local lib_name="$1"

    echo "remove '$lib_name' from $dest"
    tpl -i $G_BASH_LIB/tpls/inputrc_include.tpl -d -I "$lib_name" -o $dest
}

gblcmd_list(){
    for i in $(cat $dest | grep "#GIT_BASH_LIB.inputrc_include_" | grep -v "_END")
    do
        local lib_name=${i:30}
        [ "$lib_name" != "" ] && echo $lib_name
    done
    echo "Available for in GBashLib:"
    for i in $(ls $G_BASH_LIB/$lib_dir/)
    do
        local lib_name=${i:0:-12}
        [ "$lib_name" != "" ] && echo -e "\t$lib_name"
    done
}

#run G_BASH_LIB
[ -z "$G_BASH_LIB" ] && { echo -e "!!!!\nFATAL ERROR: G_BASH_LIB variable is not set!\nAdd it in ~/.bashrc or use export G_BASH_LIB=path_to_the_lib"; exit 1; }
. "$G_BASH_LIB/GBashLib.sh"

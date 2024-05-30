#!/bin/bash
export G_BASH_LIB=GBL_PATH

function main(){
    local cmd="$1"
    local path="$G_BASH_LIB/libs/$1.lib.sh"
    if [ "$cmd" == "tpl" ] ; then
        path=$G_BASH_LIB/tpls/$2.tpl
        if [ -f "$path" ] ; then
            echo "$path"
        fi
    elif [ "$cmd" == "d_lib" ] ; then
        path=$G_BASH_LIB/d_libs/d_$2.bl.sh
        if [ -f "$path" ] ; then
            echo "$path"
        fi
    elif [ "$cmd" == "gbl" ] ; then
        echo $G_BASH_LIB
    else
        if [ -f "$path" ] ; then
            echo "$path"
        fi
    fi
}
main "$@"

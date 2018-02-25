#!/bin/bash

function main(){
	local cmd=$1
	local path=$G_BASH_LIB/libs/$1.lib.sh
	if [ -f $path ] ; then
		echo $path
	fi
}
main $@
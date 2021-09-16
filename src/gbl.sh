#!/bin/bash
function main(){
	local cmd="$1"
  local path="$G_BASH_LIB/libs/$1.lib.sh"
  if [ "$cmd" == "tpl" ] ; then
      path=$G_BASH_LIB/tpls/$2.tpl
      if [ -f "$path" ] ; then
          echo "$path"
      fi
  else
      if [ -f "$path" ] ; then
          echo "$path"
      fi
  fi
}
main $@

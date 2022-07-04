export G_BASH_LIB=$(dirname "${BASH_SOURCE[0]}")

eval "$(r _print_autocomplete r)"
eval "$(d _print_autocomplete d)"

# generate autoComplete
_gbl_autoComplete(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    local bin=${COMP_WORDS[0]}
    #echo "${COMP_WORDS[@]}"
    #echo "$COMP_KEY"
    #echo "$COMP_LINE"
    #echo $COMP_CWORD
    COMPREPLY=( $(compgen -W "$(autoComplete _get $COMP_CWORD ${COMP_WORDS[@]} )") )
}

if type complete >/dev/null 2>&1 ; then
    ac_list=$(autoComplete _list)
    for ac in ${ac_list[@]} ; do
        complete -r $ac _gbl_autoComplete >/dev/null 2>&1; #firts remove old j autocomplete
        complete -F _gbl_autoComplete $ac
    done
fi


# 'j' jump Shortcut
_gbl_my_jump(){

    case "$1" in
    "get")
        v get -t path "$2"
        return 0;
    ;;
    "set")
        local p="$3"
        [[ "$3" == "." ]] && p=$(pwd)
        v set -t path "$2=$p"
        return 0;
    ;;
    "del")
        shift
        v del -t path $@
        return 0
    ;;
    "list")
        v list -dt path | column -t -n
        return 0
    ;;
    esac

    [[  -z "$1" ]] && {
        echo -e "usage to jump: $COLOR_GREEN j J_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN j set J_ALIAS PATH$COLOR_NONE\n\
usage to del: $COLOR_GREEN j del J_ALIAS $COLOR_NONE\n\
usage to list: $COLOR_GREEN j$COLOR_NONE or $COLOR_GREEN j list$COLOR_NONE "
        v list -dt path | column -t -n
        return 0
    }
    local location
    location=$( v get -t path "$1" )
    [[ "$location" == "" ]] && {
        location=($(v list -t path -n  | grep "$1"))
        if [[ ${#location[@]} == 0 ]] ; then
            echo -e "location is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN j set $1 PATH$COLOR_NONE'"
            return 1
    elif [ ${#location[@]} -gt 1 ] ; then
            echo -e "location $1 is ambigues: (${location[@]})"
            return 1
        else
            echo "$1 -> $location"
            location=$(v get -t path $location )
        fi
    }
    echo -e "\tjump to $COLOR_GREEN $location $COLOR_NONE"
    cd "$location"
}

_gbl_bac_jump_alias(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    conns="$(v list -nt path | grep "$cur")"
    if [ "$COMP_CWORD" -gt 1 ] ; then
        case "$prev" in
            "get"|"set")
            ;;
            *)
                conns= ;
            ;;
        esac
    else
        conns="$conns $(echo -e "get\nset\nlist" | grep "$cur") "
    fi


    COMPREPLY=( $(compgen -W "$conns") )
} ;
if type complete >/dev/null 2>&1 ; then
    complete -r j _gbl_bac_jump_alias >/dev/null 2>&1; #firts remove old j autocomplete
    complete -F _gbl_bac_jump_alias j
fi

alias j="_gbl_my_jump"

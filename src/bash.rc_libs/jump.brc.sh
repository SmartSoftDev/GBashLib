
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
        v list -dt path
        return 0
    ;;
    esac

    [[ -z "$1" ]] && {
        echo -e "usage to jump: $COLOR_GREEN j J_ALIAS$COLOR_NONE\n\
usage to set: $COLOR_GREEN j set J_ALIAS PATH$COLOR_NONE\n\
usage to del: $COLOR_GREEN j del J_ALIAS $COLOR_NONE\n\
usage to list: $COLOR_GREEN j$COLOR_NONE or $COLOR_GREEN j list$COLOR_NONE "
        v list -dt path
        return 0
    }
    local location location_suffix location_prefix args
    args="$@" # handle directories that have spaces in name
    location_prefix="${args%%\/*}"
    location=$( v get -t path "$location_prefix" )
    if [[ "$1" == *"/"* ]] && [ -d "$location/${args#*/}" ]; then
        location_suffix="/${args#*/}"
    fi
    if [[ "$location" == "" ]]; then
        location=($(v list -t path -n  | grep "$location_prefix"))
        if [[ ${#location[@]} == 0 ]] ; then
            echo -e "location is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN j set $location_prefix PATH$COLOR_NONE'"
            return 1
        elif [ ${#location[@]} -gt 1 ] ; then
                echo -e "location $1 is ambiguous: (${location[@]})"
                return 1
        else
            echo "$1 -> $location"
            location="$(v get -t path $location )"
        fi
    fi
    echo -e "\tjump to $COLOR_GREEN $location $COLOR_NONE"
    cd "$location$location_suffix"
}

_gbl_bac_jump_alias(){
    local cur_prefix cur_suffix cur prev conns root_dir
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    cur_prefix="${cur%%\/*}"
    conns="$(v list -nt path | grep "$cur_prefix")"
    if (( ${#cur_prefix} > 1 )) && [[ "$cur" == *"/"* ]] ;then
        conns="$(v list -nt path | grep "$cur_prefix$")"
        cur_suffix="${cur#*/}/"
    fi
    if [ "$COMP_CWORD" -gt 1 ] ; then
        case "$prev" in
            "get"|"set")
            ;;
            *)
                conns= ;
            ;;
        esac
    else
        conns="$conns $(echo -e "get\nset\nlist" | grep "$cur_prefix") "
    fi
    if [ -z "$cur_suffix" ]; then
        COMPREPLY=( $(compgen -W "$conns") )
    else
        local location
        location=($(v list -t path -n  | grep "^$cur_prefix$"))
        if [[ ${#location[@]} == 0 ]] ; then
            echo -e "location is $COLOR_RED NOT-SET $COLOR_NONE use '$COLOR_GREEN j set $1 PATH$COLOR_NONE'"
            return 1
        elif [ ${#location[@]} -gt 1 ] ; then
            echo -e "location $1 is ambiguous: (${location[@]})"
            return 1
        else
            location=$(v get -t path $location )
            # trim trailing '/'
            cur_suffix="${cur_suffix%%+(/)}"
            # check if location is valid directory path
            if [ -d "$location/$cur_suffix" ];then
                location="$location/$cur_suffix"
            else
                location="$location/$cur_suffix"
                # trim last autocomplete part
                location="${location%/*}"
            fi
            while IFS=  read -r -d $'\0'; do
                elem="${REPLY#*$cur_prefix\/}"
                if [[  "$elem" == "$cur_suffix"* ]];then
                    COMPREPLY+=( "$cur_prefix/$elem/" )
                fi
            done < <(find $location -mindepth 1 -maxdepth 1 -type d -print0)
        fi
    fi
} ;
if type complete >/dev/null 2>&1 ; then
    complete -r j _gbl_bac_jump_alias >/dev/null 2>&1; #first remove old j autocomplete
    complete -o nospace -F _gbl_bac_jump_alias j
fi

alias j="_gbl_my_jump"

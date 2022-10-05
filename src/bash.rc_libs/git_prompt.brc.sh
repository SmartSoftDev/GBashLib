DEFAULT_PROMPT_CONFIG="no_change"
DEFAULT_PROMPT_MIN_CHARS=40
DEFAULT_PROMPT_MAX_LEN=60

function prompt_eval(){
    local prompt="${ORIGINAL_PS1}"
    local new_line_config=${1}
    local add_new_line=false
    if [[ ${new_line_config} == "always" || ${new_line_config} == "conditional" ]]; then
        add_new_line=true
    fi
    if [[ -e /etc/bash_completion.d/git-prompt ]]; then
        prompt='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h:\[\033[01;33m\]$(__git_ps1 " (%s)") \[\033[01;34m\]\w\[\033[00m\]'
        # the resulting prompt string, without colors
        local prompt_res=$(echo ${prompt@P} | sed 's/\x1B\[[0-9;]*[JKmsu]//g')
        local prompt_len=${#prompt_res}
        # terminal's line length in characters
        local line_len=$(stty size | awk '{print $2}')
        local available_chars=$((${line_len}-${prompt_len}-2))
        # don't add a new line to bash prompt if there is enough space left
        # for commands and the prompt is short
        if [[ ${new_line_config} == "conditional" &&
              ${available_chars} -ge ${PROMPT_MIN_CHARS} &&
              ${prompt_len} -lt ${PROMPT_MAX_LEN} ]]
        then
            add_new_line=false
        fi
        if [[ ${add_new_line} == "true" ]]; then
            prompt="${prompt}\n\$ "
        else
            prompt="${prompt}\$ "
        fi

    fi
    PS1="${prompt}"
    echo -ne "\033]0;${HOSTNAME}:$(__git_ps1 " (%s)") ${PWD}\007"
}

function read_config(){
    # config priority: bash config -> v -> hardcoded
    which v > /dev/null 2>&1
    if [ ${?} -eq 0 ]; then
        PROMPT_CONFIG=${PROMPT_CONFIG:-$(v get PROMPT_CONFIG)}
        PROMPT_MIN_CHARS=${PROMPT_MIN_CHARS:-$(v get PROMPT_MIN_CHARS)}
        PROMPT_MAX_LEN=${PROMPT_MAX_LEN:-$(v get PROMPT_MAX_LEN)}
    fi
    PROMPT_CONFIG=${PROMPT_CONFIG:-$DEFAULT_PROMPT_CONFIG}
    PROMPT_MIN_CHARS=${PROMPT_MIN_CHARS:-$DEFAULT_PROMPT_MIN_CHARS}
    PROMPT_MAX_LEN=${PROMPT_MAX_LEN:-$DEFAULT_PROMPT_MAX_LEN}
}

if [[ -e /etc/bash_completion.d/git-prompt ]]; then
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWDIRTYSTATE="yes"
    GIT_PS1_SHOWCOLORHINTS="yes"
    . /etc/bash_completion.d/git-prompt
fi

read_config

ORIGINAL_PS1="${PS1}"
case $PROMPT_CONFIG in
    "new_line_always")
        PROMPT_COMMAND="prompt_eval always";;
    "new_line_conditional")
        PROMPT_COMMAND="prompt_eval conditional";;
    "no_change")
        ;;
    *)
        PROMPT_COMMAND="prompt_eval never";;
esac

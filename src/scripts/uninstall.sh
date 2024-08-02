#!/bin/bash
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)

. $(gbl log)

set -e
declare -a INSTALLED_BINS=("v" "tpl" "uidgen" "autoComplete" "to_json_yaml"
"d" "r" "gbl" "mng_bashrc" "mng_gitconfig" "mng_inputrc" )


log "Cleanup bashrc..."

if [ -f "$HOME/.bashrc" ]; then
    tpl -i "$DIR/tpls/bashrc.tpl" -d -o "$HOME/.bashrc"
    sudo tpl -i "$DIR/tpls/bashrc.tpl" -d -o "/root/.bashrc"
fi

mng_bashrc remove git
mng_bashrc remove find
mng_bashrc remove git_prompt
mng_bashrc remove python
mng_bashrc remove systemd
mng_bashrc remove terminal
mng_bashrc remove jump
mng_bashrc remove ssh
mng_bashrc remove console
mng_bashrc remove common

mng_gitconfig remove "alias"
mng_gitconfig remove http_credentials
mng_gitconfig remove push_pull
mng_gitconfig remove vscode_as_editor

mng_inputrc remove up_down_search
mng_inputrc remove usefull

log "Uninstall bins..."

for binary in "${!INSTALLED_BINS[@]}"; do
    bin_path="/bin/${INSTALLED_BINS[$binary]}"
    if [ -f "$bin_path" ]; then
        sudo rm "$bin_path"
    fi
done

declare -a G_BASH_LIB_GBL_FUNCTIONS=(
_gbl_autoComplete
_gbl_bac_console_alias
_gbl_bac_d
_gbl_bac_jump_alias
_gbl_bac_ssh_alias
_gbl_my_console
_gbl_my_console_usage
_gbl_my_jump
_gbl_my_ssh
_gbl_my_ssh_usage )

v_file="$HOME/.v.yaml"

log "Uninstall bins..."

if [ -f "$v_file" ]; then
    rm "$v_file"
fi

log "Remove GBashLib functions..."
for func in "${G_BASH_LIB_GBL_FUNCTIONS[@]}"; do
    [[ $(type -t "$func") == function ]] && unset -f "$func"
done

declare -a G_BASH_LIB_ALIASES=( b bp c egrep fd ff fgrep g ga gd gdt gg gl grep
gs j jc ll ls pull push pytest3 rg s sc screstart scst scstart scstop
)

log "Remove GBashLib aliases..."
for a in "${G_BASH_LIB_ALIASES[@]}"; do
    [[ $(type -t "$a") == alias ]] && unalias "$a"
done
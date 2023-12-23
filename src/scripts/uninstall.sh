#!/bin/bash
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)

. $(gbl log)

set -e
declare -a G_BASH_LIB_INSTALLED_BINS=("v" "tpl" "uidgen" "autoComplete" "to_json_yaml" \
"d" "r" "gbl" "mng_bashrc" "mng_gitconfig" "mng_inputrc" )

log "Uninstalling bins!"

for binary in "${!G_BASH_LIB_INSTALLED_BINS[@]}"; do
    bin_path="/bin/${G_BASH_LIB_INSTALLED_BINS[$binary]}"
    if [ -f "$bin_path" ]; then
        sudo rm "$bin_path"
    fi
done

log "Cleanup bashrc!"
if [ -f "$HOME/.bashrc" ]; then
    tpl -i "$DIR/tpls/bashrc.tpl" -d -o "$HOME/.bashrc"
    sudo tpl -i "$DIR/tpls/bashrc.tpl" -d -o /root/.bashrc
fi


log "Cleanup aliases!"
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
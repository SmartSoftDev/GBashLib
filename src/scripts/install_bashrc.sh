#!/bin/bash
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)
set -e

# bashrc for USER and root
tpl -i "$DIR/tpls/bashrc.tpl" -r -o "$HOME/.bashrc" -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"
sudo tpl -i "$DIR/tpls/bashrc.tpl" -r -o /root/.bashrc -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"

mng_bashrc add git
mng_bashrc add find
mng_bashrc add git_prompt
mng_bashrc add python
mng_bashrc add systemd
mng_bashrc add terminal
mng_bashrc add jump
mng_bashrc add ssh
mng_bashrc add console

mng_gitconfig add "alias"
mng_gitconfig add http_credentials
mng_gitconfig add push_pull

mng_inputrc add up_down_search
mng_inputrc add usefull
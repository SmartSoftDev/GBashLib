#!/bin/bash
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)
set -e

mng_bashrc add git
mng_bashrc add find
mng_bashrc add git_prompt
mng_bashrc add python
mng_bashrc add systemd
mng_bashrc add terminal
mng_bashrc add jump
mng_bashrc add ssh
mng_bashrc add console
mng_bashrc add common

mng_gitconfig add "alias"
mng_gitconfig add http_credentials
mng_gitconfig add push_pull
mng_gitconfig add vscode_as_editor

mng_inputrc add up_down_search
mng_inputrc add usefull
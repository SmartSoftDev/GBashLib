#!/bin/bash

# this script will install GBL from github, will clone it if it is not found in $HOME/ghub/bash/.
ghub_dir=$HOME/ghub/bash/
gbl_dir=$ghub_dir/GBashLib
set -e
sudo apt install git
if [ ! -d $gbl_dir ] ; then
    mkdir -p $ghub_dir
    cd $ghub_dir
    git clone https://github.com/SmartSoftDev/GBashLib.git
    cd $gbl_dir
else
    cd $gbl_dir
    git pull
fi
./src/scripts/install.sh
mng_bashrc add git
mng_bashrc add find
mng_bashrc add git_prompt
mng_bashrc add python
mng_bashrc add systemd
mng_bashrc add terminal

mng_gitconfig add "alias"
mng_gitconfig add http_credentials
mng_gitconfig add push_pull

mng_inputrc add up_down_search
mng_inputrc add usefull

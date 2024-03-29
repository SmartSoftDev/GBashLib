#!/bin/bash
SCRIPT_DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

# this script will install GBL from github, will clone it if it is not found in $HOME/ghub/bash/.
ghub_dir=$HOME/ghub/ssd/
gbl_dir=$ghub_dir/GBashLib

set -e
sudo apt install -y git
if [ ! -d $gbl_dir ] ; then
    mkdir -p $ghub_dir
    cd $ghub_dir
    git clone https://github.com/SmartSoftDev/GBashLib.git
    cd $gbl_dir
else
    cd $gbl_dir
    git pull
fi
$gbl_dir/src/scripts/install_all.sh

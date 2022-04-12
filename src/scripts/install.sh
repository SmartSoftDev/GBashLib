#!/bin/bash
DIR=$(readlink -e $(dirname "${BASH_SOURCE[0]}")/../)
set -e

sudo ln -sf "$DIR/bin/v.py" "/bin/v"
sudo ln -sf "$DIR/bin/tpl.py" "/bin/tpl"
sudo ln -sf "$DIR/bin/uidgen.py" "/bin/uidgen"
sudo ln -sf "$DIR/bin/auto_complete.py" "/bin/autoComplete"

# binaries with GBL path
sudo rm -f "/bin/d" "/bin/r" "/bin/gbl" "/bin/mng_bashrc" "/bin/mng_gitconfig" "/bin/mng_inputrc"
sudo tpl -i "$DIR/d.sh" -o "/bin/d" -v GBL_PATH=$DIR
sudo tpl -i "$DIR/r.sh" -o "/bin/r" -v GBL_PATH=$DIR
sudo tpl -i "$DIR/gbl.sh" -o "/bin/gbl" -v GBL_PATH=$DIR
sudo tpl -i "$DIR/bin/mng_bashrc.sh" -o "/bin/mng_bashrc" -v GBL_PATH=$DIR
sudo tpl -i "$DIR/bin/mng_gitconfig.sh" -o "/bin/mng_gitconfig" -v GBL_PATH=$DIR
sudo tpl -i "$DIR/bin/mng_inputrc.sh" -o "/bin/mng_inputrc" -v GBL_PATH=$DIR
sudo chmod +x "/bin/d" "/bin/r" "/bin/gbl" "/bin/mng_bashrc" "/bin/mng_gitconfig" "/bin/mng_inputrc"

# bashrc for USER and root
tpl -i "$DIR/tpls/bashrc.tpl" -r -o "$HOME/.bashrc" -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"
sudo tpl -i "$DIR/tpls/bashrc.tpl" -r -o /root/.bashrc -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"

# dependencies
sudo -H apt install -y python3 python3-pip bsdmainutils
sudo -H pip3 install --upgrade pyyaml tabulate python-gnupg

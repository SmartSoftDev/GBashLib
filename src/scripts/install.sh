#!/bin/bash
DIR=$(readlink -e $(dirname ${BASH_SOURCE[0]})/../)

sudo ln -sf $DIR/d.sh /bin/d
sudo ln -sf $DIR/r.sh /bin/r
sudo ln -sf $DIR/bin/v.py /bin/v
sudo ln -sf $DIR/bin/tpl.py /bin/tpl
sudo ln -sf $DIR/bin/uidgen.py /bin/uidgen
sudo ln -sf $DIR/bin/auto_complete.py /bin/autoComplete
sudo ln -sf $DIR/gbl.sh /bin/gbl

tpl -i $DIR/tpls/bashrc.tpl -r -o $HOME/.bashrc -v BASHRC_INC=$DIR/gbl_bashrc.inc.sh
sudo tpl -i $DIR/tpls/bashrc.tpl -r -o /root/.bashrc -v BASHRC_INC=$DIR/gbl_bashrc.inc.sh
sudo -H apt install -y python-pip
sudo -H pip install --upgrade pyyaml tabulate

export G_BASH_LIB=$DIR
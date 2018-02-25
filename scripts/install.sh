#!/bin/bash
DIR=$(readlink -e $(dirname ${BASH_SOURCE[0]})/../)

sudo ln -sf $DIR/d.sh /bin/d
sudo ln -sf $DIR/r.sh /bin/r
sudo ln -sf $DIR/bin/v.py /bin/v
sudo ln -sf $DIR/bin/tpl.py /bin/tpl
sudo ln -sf $DIR/bin/auto_complete.py /bin/autoComplete
sudo ln -sf $DIR/gbl.sh /bin/gbl

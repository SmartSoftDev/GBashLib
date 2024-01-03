#!/bin/bash
SCRIPT_DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)
set -e

$SCRIPT_DIR/install_dependencies.sh
$SCRIPT_DIR/install_bins.sh

# bashrc for USER and root
tpl -i "$DIR/tpls/bashrc.tpl" -r -o "$HOME/.bashrc" -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"
sudo tpl -i "$DIR/tpls/bashrc.tpl" -r -o /root/.bashrc -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"

$SCRIPT_DIR/install_bashrc.sh


# reload .bashrc after install
exec "$BASH"
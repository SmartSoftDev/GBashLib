#!/bin/bash
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)
set -e

declare -A G_BASH_LIB_BINS=( \
    ["v.py"]="v" \
    ["tpl.py"]="tpl" \
    ["uidgen.py"]="uidgen" \
    ["auto_complete.py"]="autoComplete" \
    ["to_json_yaml.py"]="to_json_yaml" \
)

declare -A G_BASH_LIB_GBL_BINS=( \
    ["d.sh"]="d" \
    ["r.sh"]="r" \
    ["gbl.sh"]="gbl" \
    ["bin/mng_bashrc.sh"]="mng_bashrc" \
    ["bin/mng_gitconfig.sh"]="mng_gitconfig" \
    ["bin/mng_inputrc.sh"]="mng_inputrc" \
)

for binary in "${!G_BASH_LIB_BINS[@]}"; do
    bin_path="/bin/${G_BASH_LIB_BINS[$binary]}"
    if [ ! -f "$bin_path" ]; then
        sudo ln -sf "$DIR/bin/${binary}" "$bin_path"
    fi
done

for binary in "${!_BASH_LIB_GBL_BINS[@]}"; do
    bin_path="/bin/${_BASH_LIB_GBL_BINS[$binary]}"
    if [ ! -f "$bin_path" ]; then
        sudo rm "$bin_path"
    fi
    sudo tpl -i "$DIR/${binary}" -o "${bin_path}" -v GBL_PATH=$DIR
    sudo chmod +x "${bin_path}"
done

# bashrc for USER and root
tpl -i "$DIR/tpls/bashrc.tpl" -r -o "$HOME/.bashrc" -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"
sudo tpl -i "$DIR/tpls/bashrc.tpl" -r -o /root/.bashrc -v "BASHRC_INC=$DIR/gbl_bashrc.inc.sh"

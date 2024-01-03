#!/bin/bash
DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/../)
set -e

declare -A BINS=(
    ["v.py"]="v"
    ["tpl.py"]="tpl"
    ["uidgen.py"]="uidgen"
    ["auto_complete.py"]="autoComplete"
    ["to_json_yaml.py"]="to_json_yaml"
)

declare -A GBL_BINS=(
    ["d.sh"]="d"
    ["r.sh"]="r"
    ["gbl.sh"]="gbl"
    ["bin/mng_bashrc.sh"]="mng_bashrc"
    ["bin/mng_gitconfig.sh"]="mng_gitconfig"
    ["bin/mng_inputrc.sh"]="mng_inputrc"
)

for binary in "${!BINS[@]}"; do
    bin_path="/bin/${BINS[$binary]}"
    if [ ! -f "$bin_path" ]; then
        sudo ln -sf "$DIR/bin/${binary}" "$bin_path"
    fi
done

for binary in "${!GBL_BINS[@]}"; do
    bin_path="/bin/${GBL_BINS[$binary]}"
    if [ -f "$bin_path" ]; then
        sudo rm "$bin_path"
    fi
    sudo tpl -i "$DIR/${binary}" -o "${bin_path}" -v "GBL_PATH=$DIR" -p +x
done


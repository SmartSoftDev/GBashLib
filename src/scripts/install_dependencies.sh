#!/bin/bash
set -e
SCRIPT_DIR=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
REPO=$(readlink -f $SCRIPT_DIR/../../)
. $REPO/src/libs/osDetection.lib.sh

sudo -H apt install -y python3 python3-pip bsdmainutils
if is_os ubuntu_24 ; then
    echo "FYI: Setting break-system-packages = true for PIP in /etc/pip.conf"
    sudo cp $REPO/src/scripts/confs/ubuntu_24_pip.conf /etc/pip.conf
    sudo -H apt install -y python3-yaml
    sudo -H pip3 install --upgrade tabulate python-gnupg
else
    sudo -H pip3 install --upgrade pyyaml tabulate python-gnupg
fi
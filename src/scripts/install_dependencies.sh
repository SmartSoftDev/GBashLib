#!/bin/bash
DIR=$(readlink -e $(dirname "${BASH_SOURCE[0]}")/../)
set -e
sudo -H apt install -y python3 python3-pip bsdmainutils
sudo -H pip3 install --upgrade pyyaml tabulate python-gnupg

#!/bin/bash
set -e
sudo -H apt install -y python3 python3-pip bsdmainutils
sudo -H pip3 install --upgrade pyyaml tabulate python-gnupg

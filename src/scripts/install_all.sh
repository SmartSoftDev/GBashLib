#!/bin/bash
SCRIPT_DIR=$(readlink -e $(dirname "${BASH_SOURCE[0]}"))
set -e

$SCRIPT_DIR/install_dependencies.sh
$SCRIPT_DIR/install_bins.sh
$SCRIPT_DIR/install_bashrc.sh
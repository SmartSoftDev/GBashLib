#!/bin/bash
DIR=$(readlink -e $(dirname "${BASH_SOURCE[0]}")/../)
set -e

$DIR/install_dependencies.sh
$DIR/install_bins.sh
$DIR/install_bashrc.sh
#!/bin/bash
if [ -f /usr/bin/sudo ] || [ -f /bin/sudo ] ; then
    echo "REAL SUDO EXISTS! do not use the pseudo one"
    exit 1
fi
$@
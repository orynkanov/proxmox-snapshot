#!/bin/bash

VMIDS=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2 | sort -r)

for VMID in $VMIDS; do
    /usr/local/bin/shutdown-vm.sh "$VMID"
done

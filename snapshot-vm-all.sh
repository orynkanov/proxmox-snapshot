#!/bin/bash

VMIDS=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2)

for VMID in $VMIDS; do
    /usr/local/bin/snapshot-vm.sh "$VMID"
done

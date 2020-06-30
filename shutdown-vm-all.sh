#!/bin/bash

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

VMIDS=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2 | sort -r)

for VMID in $VMIDS; do
    "$SCRIPTDIR"/shutdown-vm.sh "$VMID"
done

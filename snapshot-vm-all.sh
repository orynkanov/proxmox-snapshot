#!/bin/bash

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

VMIDS=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2)

for VMID in $VMIDS; do
    "$SCRIPTDIR"/snapshot-vm.sh "$VMID"
done

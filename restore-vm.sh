#!/bin/bash

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ -z "$1" ]]; then
    echo Require VMID
    exit 1
fi

VMIDS=$*

BACKUPSTORAGE=$(pvesm status -content backup | grep -v Name | sort -k3 -n | head -n1 | awk '{print $1}')

for VMID in $VMIDS; do
    BACKUPCOUNT=$(pvesm list "$BACKUPSTORAGE" -content backup -vmid "$VMID" | grep -v Volid | grep -c "$VMID")
    if [[ $BACKUPCOUNT -eq 0 ]]; then
        echo Skip remove "$VMID" "$VMNAME" - backup not exist!
    else
        VMNAME=$(qm config "$VMID" | grep name | cut -d':' -f2)
        "$SCRIPTDIR"/shutdown-vm.sh "$VMID"
        echo Remove VM "$VMID" "$VMNAME"
        qm destroy "$VMID" -purge true

        BACKUPLAST=$(pvesm list "$BACKUPSTORAGE" -content backup -vmid "$VMID" | grep -v Volid | grep "$VMID" | tail -n1 | awk '{print $1}')
        BACKUPPATH=$(pvesm path "$BACKUPLAST")
        echo Restore backup for "$VMID" "$VMNAME"
        qmrestore "$BACKUPPATH" "$VMID"
    fi
done

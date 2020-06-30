#!/bin/bash

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ -z "$1" ]]; then
    echo Require VMID
    exit 1
fi

VMIDS=$*

BACKUPSTORAGE=$(pvesm status -content backup | grep -v Name | awk '{print $1}')
NODENAME=$(jq .nodename /etc/pve/.members | sed 's/"//g')

for VMID in $VMIDS; do
    VMIDEXIST=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2 | grep -c "$VMID")
    if [[ $VMIDEXIST -eq 1 ]]; then
        VMISRUN=$(qm status "$VMID" | cut -d':' -f2 | grep -c running)
        "$SCRIPTDIR"/shutdown-vm.sh "$VMID"
        VMNAME=$(qm config "$VMID" | grep name | cut -d':' -f2)

        echo Create new backup for "$VMID" "$VMNAME"
        vzdump "$VMID" --remove 1 --storage "$BACKUPSTORAGE" --node "$NODENAME" --mode snapshot --compress zstd
        sleep 5s
        
        if [[ $VMISRUN -eq 1 ]]; then
            "$SCRIPTDIR"/start-vm.sh "$VMID"
        fi
    else
        echo VMID "$VMID" not exist
    fi
done

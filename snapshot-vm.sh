#!/bin/bash

if [[ -z "$1" ]]; then
  echo Require VMID
  exit 1
fi

VMIDS=$*

for VMID in $VMIDS; do
  VMIDEXIST=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2 | grep -c "$VMID")
  if [[ $VMIDEXIST -eq 1 ]]; then
    VMISRUN=$(qm status "$VMID" | cut -d':' -f2 | grep -c running)
    /usr/local/bin/shutdown-vm.sh "$VMID"
    VMNAME=$(qm config "$VMID" | grep name | cut -d':' -f2)
    SNAPS=$(qm listsnapshot "$VMID" | grep -P -o 's\d+')
    for SNAP in $SNAPS; do
      echo Remove old snapshot "$SNAP" for "$VMNAME"
      qm delsnapshot "$VMID" "$SNAP"
      sleep 5s
    done
    echo Create new snapshot s0 for "$VMID" "$VMNAME"
    qm snapshot "$VMID" s0
    sleep 5s
    if [[ $VMISRUN -eq 1 ]]; then
      /usr/local/bin/start-vm.sh "$VMID"
    fi
  else
    echo VMID "$VMID" not exist
  fi
done

#!/bin/bash

if [[ -z "$1" ]]; then
  echo Require VMID
  exit 1
fi

VMIDS=$*

for VMID in $VMIDS; do
  VMIDEXIST=$(qm list | grep -v VMID | sed 's/ */ /' | cut -d' ' -f2 | grep -c "$VMID")
  if [[ $VMIDEXIST -eq 1 ]]; then
    VMNAME=$(qm config "$VMID" | grep name | cut -d':' -f2)
    echo Start "$VMID" "$VMNAME"
    qm start "$VMID"
    sleep 30s
  else
    echo VMID "$VMID" not exist
  fi
done

#!/bin/bash

# original file:
# https://github.com/aboullaite/useful-scripts/blob/master/kvm-restart-network.sh

set -e
set -u

NET_NAME=default
NET_HOOK=/etc/libvirt/hooks/qemu

virsh net-destroy $NET_NAME
virsh net-start $NET_NAME

VMS=$( virsh list | tail -n +3 | head -n -1 | awk '{ print $2; }' )

for m in $VMS ; do

    echo "$m"
    MAC_ADDR=$(virsh domiflist "$m" |grep -o -E "([0-9a-f]{2}:){5}([0-9a-f]{2})")
    NET_MODEL=$(virsh domiflist "$m" | tail -n +3 | head -n -1 | awk '{ print $4; }')

    set +e
    virsh detach-interface "$m" network --mac "$MAC_ADDR" && sleep 3
    virsh attach-interface "$m" network $NET_NAME --mac "$MAC_ADDR" --model "$NET_MODEL"
    set -e

    $NET_HOOK "$m" stopped && sleep 3
    $NET_HOOK "$m" start

done

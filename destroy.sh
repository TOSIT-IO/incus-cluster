#!/usr/bin/env bash

source  "$(dirname "$0")/incus_source.sh"

incus project switch $project

# Delete the VMs
for h in $(seq 0 $((hosts_num - 1))); do
    name=$(parseconf ".hosts[$h].hostname")
    if [[ "$name" == "null" ]]; then
    	role=$(parseconf ".hosts[$h].role");
    	qty=$(parseconf ".hosts[$h].quantity");
        if [[ "qty" == "null" ]]; then
            qty=1
        fi
        for i in $(seq 1 $qty); do
            name=$(printf "%s-%02d" "$role" "$i");
            echo "Deleting VM $name"
            incus delete $name --force
	    done
    else
	    echo "Deleting VM $name"
	    incus delete $name --force
	fi
done

# Delete storage pool and network
incus profile device remove default enp5s0
incus storage delete $storage
incus network delete $network

# Do not drop project, it’s not empty (image)
#incus project delete $project

#!/usr/bin/env bash

cd "$(dirname "$0")"

# Get customized variables
source .env


#Use incus project to namespace cluster
project=$(jq ".project" $file | sed 's/"//g')

incus project switch $project

# Delete the VMs
hostnum=$(jq '.hosts | length' $file | sed 's/"//g')
for h in $(seq 0 $((hostnum - 1))); do
    name=$(jq ".hosts[$h].hostname" $file | sed 's/"//g')
    if [[ "$name" == "null" ]]; then
	role=$(jq ".hosts[$h].role" $file | sed 's/"//g');
	qty=$(jq ".hosts[$h].quantity" $file | sed 's/"//g');
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
incus storage delete $storagepool
incus network delete $network


# Do not drop project, it’s not empty (image)
#incus project delete $project

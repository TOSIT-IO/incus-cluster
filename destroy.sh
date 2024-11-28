#!/usr/bin/env bash

cd "$(dirname "$0")"

# Get customized variables
source .env


#Use incus project to namespace cluster
project=$(jq ".project" $file | sed 's/"//g')

incus project switch $project

# Delete the VMs
hostnum=$(jq '.hosts | length' $file | sed 's/"//g')
for f in $(seq 0 $((hostnum - 1))); do
	name=$(jq ".hosts[$f].hostname" $file | sed 's/"//g')
	echo "Deleting VM $name"
	incus delete $name --force
done

# Delete storage pool and network
incus storage delete $storagepool
incus network delete $network


# Do not drop project, it’s not empty
#incus project delete $project

#!/usr/bin/env bash

cd "$(dirname "$0")"

# Get customized variables
source .env

# Delete the VMs
for f in edge-01 master-01 master-02 master-03 worker-01 worker-02 worker-03; do
	echo "Deleting VM $f"
	incus delete $f --force
done

# Delete storage pool and network 
incus storage delete $storagepool
incus network delete $network

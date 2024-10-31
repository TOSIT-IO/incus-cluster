#!/usr/bin/env bash

cd "$(dirname "$0")"

# Get customized variables
source .env

# Remove hostname configuration on loopback interface
hostnum=$(jq '.hosts | length' $file | sed 's/"//g')
for f in $(seq 0 $((hostnum - 1))); do
    name=$(jq ".hosts[$f].hostname" $file | sed 's/"//g')
    echo "$name"
    incus exec "$name" -- /bin/bash -c "
        echo $'127.0.0.1   localhost localhost.localdomain localhost4 localhost4 localdomain4 \n::1         localhost localhost.localdomain localhost6 localhost6.localdomain6 \n\n127.0.0.1 rocky8.localdomain' > /etc/hosts"
incus exec "$name" -- yum install -y firewalld
done

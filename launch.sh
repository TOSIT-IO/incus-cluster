#!/usr/bin/env bash

cd "$(dirname "$0")"

# Get customized variables
source .env

#variables extracted from incus config file
image=$(jq '.box' $file | sed 's/"//g')
hostnum=$(jq '.hosts | length' $file | sed 's/"//g')
domain=$(jq '.domain' $file | sed 's/"//g')

declare -A groups;

# check lxdbr0 network exists and is a bridge
if ! incus network list | grep $network | grep bridge ; then
	incus network create $network "ipv4.address=${iprange}" dns.domain=$domain ipv6.nat=false ipv6.address=none ipv4.nat=true
fi

# unless tdp storage exists
if ! incus storage list | grep $storagepool; then
    #create local dir storage
	mkdir -p $storagedir
	incus storage create $storagepool dir source=$storagedir
fi

yes | ssh-keygen -t rsa -b 4096 -f $privatekey -N ''

echo '#Generated by tdp-incus/launch.sh' > ${hostfile}.tmp
echo "" >> ${hostfile}.tmp

#foreach hostnum
for f in $(seq 0 $((hostnum - 1))); do
    name=$(jq ".hosts[$f].hostname" $file | sed 's/"//g')
	memory=$(jq ".hosts[$f].memory" $file)
	cpu=$(jq ".hosts[$f].cpus" $file)
	ip=$(jq ".hosts[$f].ip" $file | sed 's/"//g')
	for i in $(jq ".hosts[$f].groups[]" $file | sed 's/"//g'); do
        groups[$i]="${groups[$i]}\n$name"
    done;
    echo "$name ansible_ssh_host=$ip ansible_ssh_port=22 ansible_ssh_user='$user' ansible_ssh_private_key_file='tdp-incus/$privatekey' ip=$ip domain=$domain" >> ${hostfile}.tmp
    incus launch images:$image $name --vm <<-EOF
config:
  limits.memory: ${memory}MB
  limits.cpu: ${cpu}
  user.tdp-groups: $(jq -r ".hosts[$f].groups | @csv" $file | tr -d '"')
  user.user-data: |
    #cloud-config
    fqdn: ${name}.${domain}
    manage_etc_hosts: true
    package_update: true
    package_upgrade: true
    package_reboot_if_required: true
    packages:
      - openssh-server
      - vim
    write_files:
      - path: /etc/ssh/sshd_config
        content: |
          # Set UsePAM to ssh on passwd-less account
          UsePAM yes
          # SFTP not working without sftp-server path
          Subsystem sftp /usr/libexec/openssh/sftp-server
        append: true
    runcmd:
      - [ systemctl, enable, sshd, --now ]
    users:
      - name: ${user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh-authorized-keys:
          - $(cat $privatekey.pub)
        shell: /bin/bash
devices:
  root:
    path: /
    pool: tdp
    size: 50GB
    type: disk
  cloud-init:
    type: disk
    source: cloud-init:config
  agent:
    type: disk
    source: agent:config
  enp5s0:
    ipv4.address: ${ip}
    nictype: bridged
    parent: $network
    type: nic
name: $name
architecture: x86_64
profiles:
  - default
EOF
done;

echo >> ${hostfile}.tmp
for key in "${!groups[@]}"; do
    echo -e "[$key]${groups[$key]}\n" >> ${hostfile}.tmp
done

#when finished, replace host file by tmp version
mv ${hostfile}.tmp ${hostfile}

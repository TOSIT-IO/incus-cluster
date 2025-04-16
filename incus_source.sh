#!/bin/bash

error(){
    echo "$@" >&2;
    exit 1;
}

if command -v yq &>/dev/null; then
    _yq=yq
elif [ -x './yq' ]; then
    _yq='./yq'
else
    read -p "yq not installed. Do you want to install yq? Press Enter to continue (or type 'n' to skip): " answer
    if [[ "${answer}" != "n" ]]; then
        os_type=$(uname -s)
        if [[ "$os_type" == "Darwin" ]]; then
            echo "MacOS detected. Install with brew"
            brew install yq
        elif [[ "$os_type" == "Linux" ]]; then
            # Check for Arch Linux
            if [[ -f /etc/arch-release ]]; then
                sudo pacman -S yq
            else
                echo "This is a (non-Arch) Linux distribution."
                read -p "Download script and install in /usr/local/bin? (Requires sudo) Press n for local install" global
                version=`curl https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name":' | cut -d':' -f2 | sed 's/^.*\"\(.*\)\".*$/\1/g'`
                if [[ "${global}" != "n" ]]; then
                    sudo wget https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_amd64 -O /usr/local/bin/yq && \
                    sudo chmod +x /usr/local/bin/yq
                else
                    sudo wget https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_amd64 -O ./yq && \
                    sudo chmod +x ./yq
                    _yq='./yq'
                fi
            fi
        else
            echo "yq not available and OS cannot be detected. Exiting"
            exit 1;
        fi
    else
        "Do not install. Quitting..."
        exit 1
    fi
fi

config_file=$1
if [[ -z "${config_file}" ]]; then
    config_file='./incus.yml'
fi

if [[ ! -f ${config_file} ]]; then
    echo "Config file (${config_file}) not found. Quitting…"
    exit 1
fi

parseconf(){
    ${_yq} "${1}" $config_file | sed 's/"\(.*\)"/\1/g'
}

#variables extracted from incus config file
project=$(parseconf ".project // \"$(basename $PWD)\"")
echo "coucou '${project}'"
image=$(parseconf '.image // "rockylinux/8/cloud"')
hosts_num=$(parseconf '.hosts | length')
admin_user=$(parseconf '.admin_user  // "admin"')

# Network
network=$(parseconf ".network.name // \"${project}br0\"")
network_manage=$(parseconf '.network.manage // true')

# storage
storage=$(parseconf ".storage.name // \"$project\"")
storage_manage=$(parseconf '.storage.manage // true')
root_size=$(parseconf '.storage.root_size // "40GB"')

# profiles
profiles_num=$(parseconf '.profiles | length')

# output dir
generate_ansible_inventory=$(parseconf '.generate_ansible_inventory // false')
ansible_dir=`realpath $(parseconf '.ansible_dir // "./"')`
ansible_hosts_file=$(parseconf ".ansible_hosts_file // \"${ansible_dir}/inventory/hosts.ini\"")
private_key=$(parseconf ".ansible_private_key // \"${ansible_dir}/${project}_key\"")

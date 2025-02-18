#!/bin/sh

error(){
    echo "$@" >&2;
    exit 1;
}

requires(){
    error "This script requires $1 to run, please install"
}

if ! command -v incus  &>/dev/null; then
    requires 'incus'
fi
if command -v yq &>/dev/null; then
    echo 'yq is available'
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
    fi
fi

parseconf(){
    ${_yq} "${1}" incus.yml | sed 's/"\(.*\)"/\1/g'
}

#variables extracted from incus config file
project=$(parseconf '.project  // "tdp"')
image=$(parseconf '.image // "rockylinux/8/cloud"')
hosts_num=$(parseconf '.hosts | length')
admin_user=$(parseconf '.admin_user  // "tdp"')

# Network
network=$(parseconf '.network.name // "tdp"')
network_manage=$(parseconf '.network.manage // true')

# storage
storage=$(parseconf '.storage.name // "tdp"')
storage_manage=$(parseconf '.storage.manage // true')
root_size=$(parseconf '.storage.root_size // "40GB"')

# profiles
profiles_num=$(parseconf '.profiles | length')

# output dir
output_dir=`realpath $(parseconf '.output_dir // "../tdp-getting-started"')`
ansible_hosts_file="${output_dir}/inventory/hosts.ini"
private_key="$output_dir/files/tdp-rsa";

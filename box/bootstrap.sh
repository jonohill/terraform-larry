#!/usr/bin/env bash

# terraform template
# see end of file for requried variables

set -e

MAIN_USER=ubuntu
DATA_VOL_DEV=/dev/sdb

# To allow console connection for troubleshooting
set_user_password() {
    echo "ubuntu:$1" | chpasswd
}

set_ssh_host_key() {
    echo "$1" >/etc/ssh/host_key
    echo "$2" >/etc/ssh/host_key.pub
    echo "$3" >/etc/ssh/host_key-cert.pub

    echo "HostKey /etc/ssh/host_key" >>/etc/ssh/sshd_config
    echo "HostCertificate /etc/ssh/host_key-cert.pub" >>/etc/ssh/sshd_config
    chmod 600 /etc/ssh/host_key*

    systemctl restart sshd
}

# In here because Oracle rejects a "cert-authority" file
set_ssh_key() {
    ssh_dir="/home/$MAIN_USER/.ssh"
    mkdir -p "$ssh_dir"
    auth_key_file="$ssh_dir/authorized_keys"
    if ! grep "$1" "$auth_key_file"; then
        echo "$1" >>"$auth_key_file"
        chown "$MAIN_USER:$MAIN_USER" "$auth_key_file"
        chmod 600 "$auth_key_file"
    fi
}

ensure_data_vol() {
    # Await device attachment
    while [ ! -b "$DATA_VOL_DEV" ]; do
        echo "Waiting for data volume to attach..."
        sleep 1
    done
    # Partition exists?
    PART_DEV="$${DATA_VOL_DEV}1"
    if [ ! -b "$PART_DEV" ]; then
        echo 'type=83' | sfdisk "$DATA_VOL_DEV"
        mkfs.ext4 "$PART_DEV"
    fi
    # fstab update needed?
    if ! grep "$PART_DEV" </etc/fstab; then
        echo "$PART_DEV /mnt/data ext4 defaults,_netdev,nofail 0 2" >>/etc/fstab
    fi
    mkdir -p /mnt/data
    mount -a
}

ensure_docker() {
    if ! docker --version; then
        apt-get update
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo \
            "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install -y \
            containerd.io \
            docker-ce \
            docker-ce-cli \
            docker-compose
    fi
}

ensure_sops() {
    if ! sops --version; then
        # shellcheck disable=SC2094
        docker run --rm --entrypoint cat jonoh/sops /usr/local/bin/sops >/usr/local/bin/sops
        chmod +x /usr/local/bin/sops
    fi
}

compose_up() {
    # This is here to force replacement
    # shellcheck disable=SC2154
    echo "Latest hash is ${compose_sha}"

    COMPOSE_DIR="/home/$MAIN_USER/compose"
    if [ ! -d "$COMPOSE_DIR" ]; then
        git clone "$1" "$COMPOSE_DIR"
    fi
    cd "$COMPOSE_DIR"
    echo "$2" >key.txt
    if [ -x ./up.sh ]; then
        ./up.sh
    else
        git pull
        SOPS_AGE_KEY_FILE=key.txt sops exec-env secrets.enc.env 'docker-compose up -d'
    fi
    cd -
}

# The arguments here must be interpolated by terraform
# shellcheck disable=SC2016
set_user_password '${user_password}'
# shellcheck disable=SC2016
set_ssh_host_key '${ssh_host_key}' '${ssh_host_key_pub}' '${ssh_host_key_cert}'
# shellcheck disable=SC2016
set_ssh_key '${ssh_key}'
ensure_data_vol
ensure_docker
ensure_sops
# shellcheck disable=SC2016
compose_up '${compose_repo}' '${compose_sops_key}'

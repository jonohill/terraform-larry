#!/usr/bin/env bash

# terraform template
# see end of file for requried variables

set -e

MAIN_USER=ubuntu

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
    COMPOSE_DIR="/home/$MAIN_USER/compose"
    if [ ! -d "$COMPOSE_DIR" ]; then
        git clone "$1" "$COMPOSE_DIR"
    fi
    cd "$COMPOSE_DIR"
    git pull
    echo "$2" >key.txt
    SOPS_AGE_KEY_FILE=key.txt sops exec-env secrets.enc.env 'docker-compose up -d'
    rm key.txt
    cd -
}

# The arguments here must be interpolated by terraform
# shellcheck disable=SC2154
set_ssh_key "${ssh_key}"
ensure_docker
ensure_sops
# shellcheck disable=SC2154
compose_up "${compose_repo}" "${compose_sops_key}"

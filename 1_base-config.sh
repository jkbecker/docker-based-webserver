#!/bin/bash
set -e
set -o pipefail

USERNAME=${1:-admin}  
PUBKEY=${2}

adduser $USERNAME
id $USERNAME
ls -lad /home/$USERNAME/

# add to sudoers
echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers

# SSH Key Setup
mkdir -p /home/$USERNAME/.ssh/
chmod 0700 /home/$USERNAME/.ssh/
echo $PUBKEY > /home/$USERNAME/.ssh/authorized_keys

echo "Set up SSH Keys."
echo "Now updating & upgrading system."
echo "In the meantime, confirm that SSH Authentication works in a separate shell."

apt-get update && \
    apt-get dist-upgrade && \
    apt-get install \
        git \
        vim \
        ufw \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    sudo apt-key fingerprint 0EBFCD88 && \
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

apt-get update && \
    apt-get install \
        docker-ce \
        docker-ce-cli \
        containerd.io \

echo "Confirming that Docker was installed successfully:"
docker run hello-world

echo "If you know that you can log in using the user name $USERNAME,"
echo "Set PermitRootLogin no in /etc/ssh/sshd_config to prevent root from being able to SSH in."

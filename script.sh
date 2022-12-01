#!/usr/bin/env bash

set -ex

# wait on cloud-init complete (https://github.com/hashicorp/packer/issues/2639)
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'

export DEBIAN_FRONTEND=noninteractive

# install packages
apt-get update
apt-get install -y \
  net-tools \
  wget \
  curl \
  gnupg \
  lsb-release \
  jq \
  ufw \
  htop \
  ca-certificates \
  apt-transport-https \
  python3 \
  python3-apt \
  python3-pip \
  python3-distutils-extra \
  software-properties-common

# fish
apt-add-repository -y ppa:fish-shell/release-3

# docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update

DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
  fish \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin

pip3 install --upgrade pip

# set ssh with password
sed -i 's/PasswordAuthentication no*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd.service

# set timezone
timedatectl set-timezone UTC

# create ansible user
useradd \
  --create-home \
  --user-group \
  --groups sudo \
  --password "$(openssl passwd -6 -salt test "$PASSWORD")" \
  --shell /usr/bin/fish \
  "$USERNAME"

sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/.ssh
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/"$USERNAME"

cd /home/"$USERNAME"/.ssh/ || exit 1
sudo -u "$USERNAME" touch authorized_keys
echo "$PUBLIC_KEY" | tee -a authorized_keys
chmod 0640 authorized_keys

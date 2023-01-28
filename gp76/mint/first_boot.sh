#!/usr/bin/env bash

## Changing default repos
sed -i "s/packages.linuxmint.com/mirror.airenetworks.es\/linuxmint\/packages/g" /etc/apt/sources.list.d/official-package-repositories.list
sed -i "s/archive.ubuntu.com\/ubuntu/ftp.caliu.cat\/pub\/distribucions\/ubuntu\/archive/g" /etc/apt/sources.list.d/official-package-repositories.list
apt update

## Adding 32 bit support
dpkg --add-architecture i386
apt update
apt full-upgrade -y

## Installing essential build tools and ppa
apt-get install -y build-essential software-properties-common curl

## Installing nvidia drivers graphics drivers ppa
# add-apt-repository ppa:graphics-drivers/ppa -y
# apt update
# apt install -y nvidia-driver-525

## Install nvidia drivers NVIDIA CUDA repo
apt install dirmngr ca-certificates software-properties-common apt-transport-https dkms curl -y
curl -fSsL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub | gpg --dearmor | tee /usr/share/keyrings/nvidia-drivers.gpg > /dev/null 2>&1
echo 'deb [signed-by=/usr/share/keyrings/nvidia-drivers.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /' | tee /etc/apt/sources.list.d/nvidia-drivers.list
apt update
apt install nvidia-driver-525 cuda -y

## Installing xanmod kernel
echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list
wget -qO - https://dl.xanmod.org/gpg.key | apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
apt update
apt install -y linux-xanmod-x64v3

## Disabling sleep2idle
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 mem_sleep_default=deep"/' /etc/default/grub
update-grub

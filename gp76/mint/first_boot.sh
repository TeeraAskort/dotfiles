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

## Installing nvidia drivers
add-apt-repository ppa:graphics-drivers/ppa -y
apt update
apt install -y nvidia-driver-525

## Installing xanmod kernel
echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list
wget -qO - https://dl.xanmod.org/gpg.key | apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
apt update
apt install -y linux-xanmod-x64v3

## Disabling sleep2idle
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 mem_sleep_default=deep"/' /etc/default/grub
update-grub

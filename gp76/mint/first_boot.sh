#!/usr/bin/env bash

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

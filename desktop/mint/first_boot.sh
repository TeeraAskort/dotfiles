#!/usr/bin/env bash

## Adding 32 bit support
dpkg --add-architecture i386
apt update
apt full-upgrade -y

## Installing essential build tools and ppa
apt-get install -y build-essential software-properties-common curl

## Installing updated mesa
add-apt-repository ppa:kisak/turtle -y
apt update
apt full-upgrade -y

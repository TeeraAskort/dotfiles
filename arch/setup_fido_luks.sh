#!/bin/bash

# Installing fido2luks
paru -S fido2luks

# Generating credentials
sudo su -c "echo FIDO2LUKS_CREDENTIAL_ID=$(fido2luks credential [NAME]) >> /etc/fido2luks.conf"

# Load config into env
set -a
. /etc/fido2luks.conf

# Add-key to luks partition
sudo -E fido2luks -i add-key /dev/disk/by-uuid/$(sudo blkid -o value -s UUID /etc/nvme0n1p2)

# Add kernel parameters 
sudo sed -i "s/options/options rd.luks.2fa=$FIDO2LUKS_CREDENTIAL_ID:$(sudo blkid -o value -s UUID /dev/nvme0n1p2)" /boot/loader/entries/arch.conf
sudo sed -i "s/options/options rd.luks.2fa=$FIDO2LUKS_CREDENTIAL_ID:$(sudo blkid -o value -s UUID /dev/nvme0n1p2)" /boot/loader/entries/arch-fallback.conf

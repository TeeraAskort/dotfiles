#!/usr/bin/env bash

nix-env -iA nixos.fido2luks

echo "Insert FIDO2 card and press a key:"
read -n 1

echo "Tap on your FIDO2 device"

export FIDO2_LABEL="/dev/nvme0n1p2 @ link-gl63-8rc" 
until cred=$(fido2luks credential "$FIDO2_LABEL")
do
	echo "There has been a problem creating the credentials for fido2luks key"
done

until fido2luks -i add-key /dev/nvme0n1p2 $cred
do
	echo "There has been a problem adding fido key to luks"
done

sed -i "s/fidochangeme/$cred/g" hardware-configuration.nix

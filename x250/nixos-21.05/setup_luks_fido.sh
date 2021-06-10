#!/usr/bin/env bash

rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TS128GMTS430S | cut -d" " -f1)

nix-env -iA nixos.fido2luks

echo "Insert FIDO2 card and press a key:"
read -n 1

echo "Tap on your FIDO2 device"

export FIDO2_LABEL="/dev/${rootDisk}2 @ link-x250" 
until cred=$(fido2luks credential "$FIDO2_LABEL")
do
	echo "There has been a problem creating the credentials for fido2luks key"
done

until fido2luks -i add-key /dev/${rootDisk}2 $cred
do
	echo "There has been a problem adding fido key to luks"
done

sed -i "s/fidochangeme/$cred/g" hardware-configuration.nix

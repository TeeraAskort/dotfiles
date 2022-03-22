#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then

	dataDiskUUID="3888fac5-6fbd-4226-a44d-b39dfd80d430"

	# Create partitions
	parts=$(blkid | grep nvme0n1 | grep -v -e "$dataDiskUUID" | cut -d":" -f1)
	for part in $(echo "$parts" | cut -d"p" -f2); do
		parted /dev/nvme0n1 -- rm $part
	done
	parted /dev/nvme0n1 -- mkpart ESP fat32 1M 512M
	parted /dev/nvme0n1 -- set 1 boot on
	parted /dev/nvme0n1 -- mkpart primary 512M 62G

	# Loop until cryptsetup succeeds formatting the partition
	until cryptsetup luksFormat /dev/nvme0n1p2
	do 
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the patition
	until cryptsetup open /dev/nvme0n1p2 luks
	do
		echo "Cryptsetup failed, trying again"
	done

	# Configure LVM
	pvcreate /dev/mapper/luks
	vgcreate lvm /dev/mapper/luks
	lvcreate -L 16G -n swap lvm
	lvcreate -l 100%FREE -n root lvm

	# Format partitions
	mkfs.xfs -f -L root /dev/lvm/root
	mkfs.vfat -F32 /dev/nvme0n1p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/nvme0n1p1 /mnt/boot

	# Generate configs
	nixos-generate-config --root /mnt

	# Get hosts file sha256
	sha256=$(nix-prefetch-url https://someonewhocares.org/hosts/zero/hosts)

	# Copy the respective configuration.nix
	if [ "$1" = "plasma" ] || [ "$1" = "kde" ]; then
		sed -i "s/changeme/$sha256/g" $directory/configuration-plasma.nix
		cp $directory/configuration-plasma.nix /mnt/etc/nixos/configuration.nix
	elif [ "$1" = "gnome" ]; then
		sed -i "s/changeme/$sha256/g" $directory/configuration.nix
		cp $directory/configuration.nix /mnt/etc/nixos/configuration.nix
	fi

	# Copy key from secondary drive to root partition
	clear 
	part=$(blkid | grep nvme0n1 | grep -e "$dataDiskUUID" | cut -d":" -f1)
	echo "Enter data disk password"
	until cryptsetup open $part datos
	do
		echo "Cryptsetup failed opening the secondary drive"
	done
	mkdir $directory/datos
	mount /dev/mapper/datos $directory/datos
	cp $directory/datos/.keyfile /mnt

	# Put correct UUID on hardware-configuration.nix
	uuid=$(blkid -o value -s UUID /dev/nvme0n1p2)
	sed -i "s/UUIDchangeme/$uuid/g" $directory/hardware-configuration.nix

	# Add boot partition to hardware-config
	sed -i "s/bootChangeme/$(blkid -s UUID -o value /dev/nvme0n1p1)/g" $directory/hardware-configuration.nix

	# Add swap partition to hardware-config
	sed -i "s/swapChangeme/$(blkid -s UUID -o value /dev/lvm/swap)/g" $directory/hardware-configuration.nix

	# Copy hardware-config to /mnt
	cp $directory/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix

	# Install nixos
	nixos-install

else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"
fi

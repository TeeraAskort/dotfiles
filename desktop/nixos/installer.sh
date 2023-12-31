#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "cinnamon" ]]; then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep MZVLQ512HALU-000H1 | cut -d" " -f1)
	dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep SNVS2000G | cut -d" " -f1)
	torrentDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep DT01ACA300 | cut -d" " -f1)

	# Create partitions
	parted /dev/$rootDisk -- mklabel gpt
	parted /dev/$rootDisk -- mkpart ESP fat32 1M 512M
	parted /dev/$rootDisk -- set 1 boot on
	parted /dev/$rootDisk -- mkpart primary 512M 100%

	# Loop until cryptsetup succeeds formatting the partition
	until cryptsetup luksFormat /dev/${rootDisk}p2 
	do 
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the patition
	until cryptsetup open /dev/${rootDisk}p2 luks
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
	mkfs.vfat -F32 /dev/${rootDisk}p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/${rootDisk}p1 /mnt/boot

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
	elif [ "$1" = "cinnamon" ]; then
		sed -i "s/changeme/$sha256/g" $directory/configuration-cinnamon.nix
		cp $directory/configuration-cinnamon.nix /mnt/etc/nixos/configuration.nix
	fi

	# Copy key from data drive to root partition
	clear 
	echo "Enter data disk password"
	until cryptsetup open /dev/${dataDisk}p1 datos
	do
		echo "Cryptsetup failed opening the secondary drive"
	done
	mkdir $directory/datos
	mount /dev/mapper/datos $directory/datos
	cp $directory/datos/.datoskey /mnt

	# Copy key from torrent drive to root partition
	clear 
	echo "Enter torrent disk password"
	until cryptsetup open /dev/${torrentDisk}1 torrent
	do
		echo "Cryptsetup failed opening the secondary drive"
	done
	mkdir $directory/torrent
	mount /dev/mapper/torrent $directory/torrent
	cp $directory/torrent/.keyfile /mnt

	# Put correct UUID on hardware-configuration.nix
	uuid=$(blkid -o value -s UUID /dev/${rootDisk}p2)
	sed -i "s/UUIDchangeme/$uuid/g" $directory/hardware-configuration.nix

	# Add data disk UUID to hardware-config
	sed -i "s/dataDiskChangeme/$(blkid -s UUID -o value /dev/${dataDisk}p1)/g" $directory/hardware-configuration.nix

	# Add torrent disk UUID to hardware-config
	sed -i "s/torrentDiskChangeme/$(blkid -s UUID -o value /dev/${torrentDisk}1)/g" $directory/hardware-configuration.nix

	# Add boot partition to hardware-config
	sed -i "s/bootChangeme/$(blkid -s UUID -o value /dev/${rootDisk}p1)/g" $directory/hardware-configuration.nix

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

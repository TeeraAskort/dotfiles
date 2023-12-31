#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep "WDC WDS500G2B0C-00PXH0" | cut -d" " -f1)

	dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep WDC_WD20SPZX-00UA7T0 | cut -d" " -f1)

	# Create partitions
	parted /dev/${rootDisk} -- mklabel gpt
	parted /dev/${rootDisk} -- mkpart ESP fat32 1M 512M
	parted /dev/${rootDisk} -- set 1 boot on
	parted /dev/${rootDisk} -- mkpart primary 512M 100%

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
	lvcreate -L 100G -n root lvm
	lvcreate -l 100%FREE -n home lvm

	# Format partitions
	mkfs.btrfs -f -L home /dev/lvm/home
	mkfs.btrfs -f -L root /dev/lvm/root
	mkfs.vfat -F32 /dev/${rootDisk}p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/{boot,home}
	mount /dev/lvm/home /mnt/home
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
		cp -r $directory/materia-theme /mnt/etc/nixos/
		cp -r $directory/materia-kde /mnt/etc/nixos/
		cp $directory/configuration.nix /mnt/etc/nixos/configuration.nix
	fi

	# Setup fido authentication for luks device
	bash $directory/setup_luks_fido.sh

	# Copy key from secondary drive to root partition
	until cryptsetup open /dev/${dataDisk}1 datos
	do
		echo "Cryptsetup failed opening the secondary drive"
	done
	mkdir $directory/datos 
	mount /dev/mapper/datos $directory/datos 
	cp $directory/datos/.keyfile /mnt 

	# Put correct UUID on hardware-configuration.nix
	uuid=$(blkid -o value -s UUID /dev/${rootDisk}p2)
	sed -i "s/UUIDchangeme/$uuid/g" $directory/hardware-configuration.nix

	# Add data disk UUID to hardware-config
	sed -i "s/dataDiskChangeme/$(blkid -s UUID -o value /dev/${dataDisk}1)/g" $directory/hardware-configuration.nix

	# Add boot partition to hardware-config
	sed -i "s/bootChangeme/$(blkid -s UUID -o value /dev/${rootDisk}p1)/g" $directory/hardware-configuration.nix

	# Add swap partition to hardware-config
	sed -i "s/swapChangeme/$(blkid -s UUID -o value /dev/lvm/swap)/g" $directory/hardware-configuration.nix

	# Copy hardware-config to /mnt
	cp $directory/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix
	
	# Workaround for bug 
	nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=/mnt/etc/nixos/configuration.nix

	# Install nixos
	nixos-install

else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"
fi

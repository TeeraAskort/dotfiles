#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then
	# Create partitions
	parted /dev/sda -- mklabel gpt
	parted /dev/sda -- mkpart ESP fat32 1M 512M
	parted /dev/sda -- mkpart primary 512M 100%
	parted /dev/sda -- set 1 boot on

	# Loop until cryptsetup succeeds formatting the partition
	until cryptsetup luksFormat /dev/sda2
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	until cryptsetup open /dev/sda2 luks
	do
		echo "Cryptsetup failed, trying again"
	done

	# Configure LVM
	pvcreate /dev/mapper/luks
	vgcreate lvm /dev/mapper/luks
	lvcreate -L 16G -n swap lvm
	lvcreate -l 100%FREE -n root lvm

	# Format partitions
	mkfs.btrfs -f -L root /dev/lvm/root
	mkfs.vfat -F32 /dev/sda1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux-hardened linux-hardened-headers lvm2 efibootmgr btrfs-progs vim git

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]]; then
		arch-chroot /mnt bash /dotfiles/arch/laptop_arch_gnome.sh
	elif [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then
		arch-chroot /mnt bash /dotfiles/arch/laptop_arch_plasma.sh
	fi
else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"

fi 


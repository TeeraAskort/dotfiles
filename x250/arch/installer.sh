#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "cinnamon" ]]; then

        rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TS128GMTS430S | cut -d" " -f1)

	# Create partitions
	parted /dev/${rootDisk} -- mklabel gpt
	parted /dev/${rootDisk} -- mkpart ESP fat32 1M 512M
	parted /dev/${rootDisk} -- mkpart primary 512M 100%
	parted /dev/${rootDisk} -- set 1 boot on

	# Loop until cryptsetup succeeds formatting the partition
	until cryptsetup luksFormat /dev/${rootDisk}2
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	until cryptsetup open /dev/${rootDisk}2 luks
	do
		echo "Cryptsetup failed, trying again"
	done

	# Configure LVM
	pvcreate /dev/mapper/luks
	vgcreate lvm /dev/mapper/luks
	lvcreate -L 16G -n swap lvm
	lvcreate -l 100%FREE -n root lvm

	# Format partitions
	mkfs.f2fs -f -l root -O extra_attr,inode_checksum,sb_checksum /dev/lvm/root
	mkfs.vfat -F32 /dev/${rootDisk}1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/${rootDisk}1 /mnt/boot

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux-hardened lvm2 efibootmgr f2fs-tools vim git

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]]; then
		arch-chroot /mnt bash /dotfiles/x250/arch/laptop_arch_gnome.sh
	elif [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then
		arch-chroot /mnt bash /dotfiles/x250/arch/laptop_arch_plasma.sh
	elif [[ "$1" == "cinnamon" ]]; then
		arch-chroot /mnt bash /dotfiles/x250/arch/laptop_arch_cinnamon.sh
	fi
else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"
	echo "cinnamon - To install the cinnamon desktop"

fi 


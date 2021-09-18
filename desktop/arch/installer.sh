#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "mate" ]]; then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep WDS120G2G0B-00EPW0 | cut -d" " -f1)
	dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_DT01ACA300 | cut -d" " -f1)

	# Create partitions
	parted /dev/${rootDisk} -- mklabel gpt
	parted /dev/${rootDisk} -- mkpart ESP fat32 1M 512M
	parted /dev/${rootDisk} -- mkpart primary 512M 100%
	parted /dev/${rootDisk} -- set 1 boot on

	# Loop until cryptsetup succeeds formatting the partition
	echo "Enter passphrase for root disk"
	until cryptsetup luksFormat /dev/${rootDisk}2
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	echo "Enter passphrase for root disk"
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

	# Download and rank mirrors
	pacman -S pacman-contrib
	curl -s "https://archlinux.org/mirrorlist/?country=BE&country=FR&country=DE&country=LU&country=NL&country=PT&country=ES&country=CH&protocol=http&protocol=https&ip_version=4" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 10 - > /etc/pacman.d/mirrorlist

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux-zen linux-zen-headers lvm2 efibootmgr btrfs-progs vim git f2fs-tools

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_plasma.sh
	elif [[ "$1" == "gnome" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_gnome.sh
	elif [[ "$1" == "cinnamon" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_cinnamon.sh
	elif [[ "$1" == "xfce" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_xfce.sh
	elif [[ "$1" == "mate" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_mate.sh
	fi
else
	echo "Available options: "
	echo "kde or plasma - To install the plasma desktop"
	echo "gnome - To install the GNOME desktop"
	echo "cinnamon - To install the cinnamon desktop"
	echo "xfce - To install the xfce desktop"
	echo "mate - To install the mate desktop"
fi 


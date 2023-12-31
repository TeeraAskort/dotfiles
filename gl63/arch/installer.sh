#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]]; then
	# Create partitions
	parted /dev/nvme0n1 -- mklabel gpt
	parted /dev/nvme0n1 -- mkpart ESP fat32 1M 512M
	parted /dev/nvme0n1 -- mkpart primary 512M 100%
	parted /dev/nvme0n1 -- set 1 boot on

	# Loop until cryptsetup succeeds formatting the partition
	until cryptsetup luksFormat /dev/nvme0n1p2
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	until cryptsetup open /dev/nvme0n1p2 luks
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
	mkfs.xfs -f -L home /dev/lvm/home
	mkfs.xfs -f -L root /dev/lvm/root
	mkfs.vfat -F32 /dev/nvme0n1p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/{boot,home}
	mount /dev/lvm/home /mnt/home
	mount /dev/nvme0n1p1 /mnt/boot

	# Updating keyring
	pacman -Sy --noconfirm archlinux-keyring

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux-zen linux-zen-headers efibootmgr btrfs-progs vim git cryptsetup lvm2 xfsprogs

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
		arch-chroot /mnt bash /dotfiles/gl63/arch/desktop_install.sh "$1" "gtk"
	else
		arch-chroot /mnt bash /dotfiles/gl63/arch/desktop_install.sh "$1" "qt"
	fi
else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"
	echo "xfce - To install the xfce desktop"
	echo "cinnamon - To install the cinnamon desktop"
	echo "mate - To install the mate desktop"

fi 


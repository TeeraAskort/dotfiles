#!/bin/bash

dataDiskUUID="e3839618-a2ea-4043-9359-9906c76eee0e"

# Checking if arguments are passed
if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "el" ]]; then
	# Create partitions
	parts=$(blkid | grep nvme0n1 | grep -v -e "$dataDiskUUID" | cut -d":" -f1)
	for part in $(echo "$parts" | cut -d"p" -f2); do
		parted /dev/nvme0n1 -- rm $part
	done
	parted /dev/nvme0n1 -- mkpart ESP fat32 1M 1GiB
	parted /dev/nvme0n1 -- set 1 boot on
	parted /dev/nvme0n1 -- mkpart primary 1GiB 100GiB

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
	lvcreate -L 32G -n swap lvm
	lvcreate -l 100%FREE -n root lvm

	# Format partitions
	mkfs.btrfs -L root /dev/lvm/root
	mkfs.vfat -F32 /dev/nvme0n1p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/nvme0n1p1 /mnt/boot

	# Updating keyring
	pacman -Sy --noconfirm archlinux-keyring

	# Install base system
	pacstrap /mnt base base-devel linux-firmware sof-firmware efibootmgr btrfs-progs vim git cryptsetup lvm2 xfsprogs 

	# Executing partprobe
	partprobe /dev/nvme0n1

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
		arch-chroot /mnt bash /dotfiles/gp76/arch/desktop_install.sh "$1" "gtk" 
	elif [[ "$1" == "el" ]]; then 
		arch-chroot /mnt bash /dotfiles/gp76/arch/desktop_install.sh "$1"
	else
		arch-chroot /mnt bash /dotfiles/gp76/arch/desktop_install.sh "$1" "qt" 
	fi
else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"
	echo "xfce - To install the xfce desktop"
	echo "cinnamon - To install the cinnamon desktop"
	echo "mate - To install the mate desktop"
	echo "el - To install the enlightenment desktop"

fi 


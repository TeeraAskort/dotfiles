#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "el" ]]; then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep MZVLQ512HALU-000H1 | cut -d" " -f1)
	dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_DT01ACA300 | cut -d" " -f1)

	# Create partitions
	parted /dev/${rootDisk} -- mklabel gpt
	parted /dev/${rootDisk} -- mkpart ESP fat32 1M 512MiB
	parted /dev/${rootDisk} -- mkpart primary 512MiB 2GiB
	parted /dev/${rootDisk} -- mkpart primary 2GiB 100%
	parted /dev/${rootDisk} -- set 1 boot on

	# Loop until cryptsetup succeeds formatting the partition
	echo "Enter passphrase for root disk"
	until cryptsetup luksFormat /dev/${rootDisk}p3
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	echo "Enter passphrase for root disk"
	until cryptsetup open /dev/${rootDisk}p3 luks
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
	mkfs.ext2 -F /dev/${rootDisk}p2
	mkfs.vfat -F32 /dev/${rootDisk}p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/${rootDisk}p2 /mnt/boot
	mkdir /mnt/boot/efi
	mount /dev/${rootDisk}p1 /mnt/boot/efi

	# Updating keyring
	pacman -Sy --noconfirm archlinux-keyring

	# Install base system
	pacstrap /mnt base base-devel linux-firmware lvm2 efibootmgr btrfs-progs vim git xfsprogs 

	# Executing partprobe
	partprobe /dev/nvme0n1

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_install.sh "$1" "gtk" 
	elif [[ "$1" == "el" ]]; then 
		arch-chroot /mnt bash /dotfiles/340s/arch/desktop_install.sh "$1"
	else
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_install.sh "$1" "qt" 
	fi
else
	echo "Available options: "
	echo "kde or plasma - To install the plasma desktop"
	echo "gnome - To install the GNOME desktop"
	echo "cinnamon - To install the cinnamon desktop"
	echo "xfce - To install the xfce desktop"
	echo "mate - To install the mate desktop"
	echo "el - To install the enlightenment desktop"

fi 


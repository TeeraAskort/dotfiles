#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "mate" ]]; then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep MZVLQ512HALU-000H1 | cut -d" " -f1)
	dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_DT01ACA300 | cut -d" " -f1)

	# Create partitions
	parted /dev/${rootDisk} -- mklabel gpt
	parted /dev/${rootDisk} -- mkpart ESP fat32 1M 512M
	parted /dev/${rootDisk} -- mkpart primary 512M 100%
	parted /dev/${rootDisk} -- set 1 boot on

	# Loop until cryptsetup succeeds formatting the partition
	echo "Enter passphrase for root disk"
	until cryptsetup luksFormat /dev/${rootDisk}p2
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	echo "Enter passphrase for root disk"
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

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux linux-headers lvm2 efibootmgr btrfs-progs vim git xfsprogs 

	# Executing partprobe
	partprobe /dev/nvme0n1

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_install.sh "$1" "gtk" "$(blkid -g -p -s UUID -o value /dev/${rootDisk}p2)"
	else
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_install.sh "$1" "qt" "$(blkid -g -p -s UUID -o value /dev/${rootDisk}p2)"
	fi
else
	echo "Available options: "
	echo "kde or plasma - To install the plasma desktop"
	echo "gnome - To install the GNOME desktop"
	echo "cinnamon - To install the cinnamon desktop"
	echo "xfce - To install the xfce desktop"
	echo "mate - To install the mate desktop"
fi 


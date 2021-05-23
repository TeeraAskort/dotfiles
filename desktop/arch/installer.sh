#!/bin/bash

# Checking if arguments are passed
if [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "gnome" ]];then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep WDC_WDS120G2G0B-00EPW0 | cut -d" " -f1)
	dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_DT01ACA300 | cut -d" " -f1)

	# Create partitions
	parted /dev/${rootDisk} -- mklabel gpt
	parted /dev/${rootDisk} -- mkpart ESP fat32 1M 512M
	parted /dev/${rootDisk} -- mkpart primary 512M 100%
	parted /dev/${rootDisk} -- set 1 boot on

	parted /dev/${dataDisk} -- mklabel gpt
	parted /dev/${dataDisk} -- mkpart primary 1M 100%

	# Loop until cryptsetup succeeds formatting the partition
	echo "Enter passphrase for root disk"
	until cryptsetup luksFormat /dev/${rootDisk}2
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup suceeds formatting the partition
	echo "Enter passphrase for data disk"
	until cryptsetup luksFormat /dev/${dataDisk}1
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	echo "Enter passphrase for root disk"
	until cryptsetup open /dev/${rootDisk}2 luks
	do
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the partition
	echo "Enter passphrase for data disk"
	until cryptsetup open /dev/${dataDisk}1 data
	do
		echo "Cryptsetup failed, trying again"
	done

	# Configure LVM
	pvcreate /dev/mapper/luks
	vgcreate lvm /dev/mapper/luks
	lvcreate -L 16G -n swap lvm
	lvcreate -l 100%FREE -n root lvm

	# Format partitions
	mkfs.btrfs -f -L home /dev/mapper/data
	mkfs.f2fs -f -l root -O extra_attr,inode_checksum,sb_checksum /dev/lvm/root
	mkfs.vfat -F32 /dev/i${rootDisk}1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/{boot,home}
	mount /dev/mapper/data /mnt/home
	mount /dev/${rootDisk}1 /mnt/boot

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux-zen lvm2 efibootmgr btrfs-progs vim git f2fs-tools

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Generate keyfile for data disk
	dd if=/dev/random bs=32 count=1 of=/mnt/root/.keyfile
	echo "Enter data disk passphrase"
	cryptsetup luksAddKey /dev/${dataDisk}1 /mnt/root/.keyfile

	# Add key to crypttab
	echo "encrypteddata UUID=$(sudo blkid -s UUID -o value /dev/${dataDisk}1) /root/.keyfile luks,discard" | tee -a /mnt/etc/crypttab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_plasma.sh
	elif [[ "$1" == "gnome" ]]; then
		arch-chroot /mnt bash /dotfiles/desktop/arch/desktop_arch_gnome.sh
	fi
else
	echo "Available options: "
	echo "kde or plasma - To install the plasma desktop"
	echo "gnome - To install the GNOME desktop"
fi 


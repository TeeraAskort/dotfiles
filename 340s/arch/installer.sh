#!/bin/bash

dataDiskUUID="8c5af7a6-3e34-4815-b7d3-31600c0c3c28"

# Checking if arguments are passed
if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]]; then
	# Create partitions
	parts=$(blkid | grep nvme0n1 | grep -v -e "$dataDiskUUID" | cut -d":" -f1)
	for part in $(echo "$parts" | cut -d"p" -f2); do
		parted /dev/nvme0n1 -- rm $part
	done
	parted /dev/nvme0n1 -- mkpart primary 1M 512M
	parted /dev/nvme0n1 -- mkpart primary 512M 18G
	parted /dev/nvme0n1 -- mkpart primary 18G 100G

	# Format partitions
	parts=$(blkid | grep nvme0n1 | grep -v -e "$dataDiskUUID" | cut -d":" -f1)
	mkfs.vfat -F32 /dev/nvme0n1p1
	mkfs.f2fs -f -L root /dev/nvme0n1p4
	mkswap /dev/nvme0n1p3
	swapon /dev/nvme0n1p3

	# Mount paritions
	mount /dev/nvme0n1p4 /mnt
	mkdir /mnt/boot
	mount /dev/nvme0n1p1 /mnt/boot

	# Install base system
	pacstrap /mnt base base-devel linux-firmware linux linux-headers efibootmgr btrfs-progs vim git iptables-nft

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	if [[ "$1" == "gnome" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
		arch-chroot /mnt bash /dotfiles/gl63/arch/desktop_install.sh "$1" "gtk" "/dev/nvme0n1p3"
	else
		arch-chroot /mnt bash /dotfiles/gl63/arch/desktop_install.sh "$1" "qt" "/dev/nvme0n1p3"
	fi
else
	echo "Available options: "
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install the plasma desktop"
	echo "xfce - To install the xfce desktop"
	echo "cinnamon - To install the cinnamon desktop"
	echo "mate - To install the mate desktop"

fi 


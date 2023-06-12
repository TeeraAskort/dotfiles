#!/bin/bash

torrentDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep Micron_3400_MTFDKBA1T0TFH | cut -d" " -f1)
dataDiskUUID="e3839618-a2ea-4043-9359-9906c76eee0e"

# Checking if arguments are passed
if [[ "$1" == "gnome" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == "kde" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "el" ]]; then
	# Create partitions
	parts=$(blkid | grep $torrentDisk | grep -v -e "$dataDiskUUID" | cut -d":" -f1)
	for part in $(echo "$parts" | cut -d"p" -f2); do
		parted /dev/$torrentDisk -- rm $part
	done
	parted /dev/$torrentDisk -- mkpart ESP fat32 1M 512MiB
	parted /dev/$torrentDisk -- set 1 boot on
	parted /dev/$torrentDisk -- mkpart primary 512MiB 100GiB

	# Loop until cryptsetup succeeds formatting the partition
	until cryptsetup luksFormat /dev/${torrentDisk}p2
	do 
		echo "Cryptsetup failed, trying again"
	done

	# Loop until cryptsetup succeeds opening the patition
	until cryptsetup open /dev/${torrentDisk}p2 luks
	do
		echo "Cryptsetup failed, trying again"
	done

	# Configure LVM
	pvcreate /dev/mapper/luks
	vgcreate lvm /dev/mapper/luks
	lvcreate -L 32G -n swap lvm
	lvcreate -l 100%FREE -n root lvm

	# Format partitions
	mkfs.ext4 -L root /dev/lvm/root
	mkfs.vfat -F32 /dev/${torrentDisk}p1
	mkswap /dev/lvm/swap
	swapon /dev/lvm/swap

	# Mount paritions
	mount /dev/lvm/root /mnt
	mkdir /mnt/boot
	mount /dev/${torrentDisk}p1 /mnt/boot

	# Updating keyring
	pacman -Sy --noconfirm archlinux-keyring

	# Rank mirrors
	pacman -S --noconfirm pacman-contrib

	curl -L "https://archlinux.org/mirrorlist/?country=BE&country=FR&country=DE&country=LU&country=NL&country=PT&country=ES&protocol=http&protocol=https&ip_version=4&ip_version=6" > /etc/pacman.d/mirrorlist
	cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
	sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
	rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
	pacman -Sy
	
	# Install base system
	pacstrap /mnt base base-devel linux-firmware sof-firmware efibootmgr btrfs-progs vim git cryptsetup lvm2 xfsprogs # aria2

	# Executing partprobe
	partprobe /dev/${torrentDisk}

	# Generate fstab
	genfstab -U /mnt >> /mnt/etc/fstab

	# Change location, clone the git repo and execute the installation script
	cd /mnt
	git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

	# Copy mirrorlist
	cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

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


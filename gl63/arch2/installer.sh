#!/bin/bash

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
mkfs.btrfs -f -L home /dev/lvm/home
mkfs.btrfs -f -L root /dev/lvm/root
mkfs.vfat -F32 /dev/nvme0n1p1
mkswap /dev/lvm/swap
swapon /dev/lvm/swap

# Mount paritions
mount /dev/lvm/root /mnt
mkdir /mnt/{boot,home}
mount /dev/lvm/home /mnt/home
mount /dev/nvme0n1p1 /mnt/boot

# Install base system
pacstrap /mnt base base-devel linux-firmware linux-hardened linux-hardened-headers lvm2 efibootmgr btrfs-progs vim git intel-ucode

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Change location, clone the git repo and execute the installation script
cd /mnt/root
git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

# Installing base system
arch-chroot /mnt bash /root/dotfiles/gl63/arch2/base.sh

# Rebooting system
reboot

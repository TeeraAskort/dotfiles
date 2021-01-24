#!/bin/bash

parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1M 512M
parted /dev/nvme0n1 -- mkpart primary 512M 100%
parted /dev/nvme0n1 -- set 1 boot on

until cryptsetup luksFormat /dev/nvme0n1p2
do
	echo "Cryptsetup failed, trying again"
done

until cryptsetup open /dev/nvme0n1p2 luks
do
	echo "Cryptsetup failed, trying again"
done

pvcreate /dev/mapper/luks

vgcreate lvm /dev/mapper/luks

lvcreate -L 16G -n swap lvm
lvcreate -L 100G -n root lvm
lvcreate -l 100%FREE -n home lvm

mkfs.btrfs -f -L home /dev/lvm/home
mkfs.btrfs -f -L root /dev/lvm/root
mkfs.vfat -F32 /dev/nvme0n1p1
mkswap /dev/lvm/swap
swapon /dev/lvm/swap

mount /dev/lvm/root /mnt
mkdir /mnt/{boot,home}
mount /dev/lvm/home /mnt/home
mount /dev/nvme0n1p1 /mnt/boot

pacstrap /mnt base base-devel linux-firmware linux-hardened linux-hardened-headers lvm2 grub efibootmgr btrfs-progs vim git

genfstab -U /mnt >> /mnt/etc/fstab

cd /mnt

git clone https://SariaAskort@bitbucket.org/SariaAskort/dotfiles.git

arch-chroot /mnt bash /dotfiles/arch/laptop_arch_plasma_config.sh

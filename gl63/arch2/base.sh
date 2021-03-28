#!/usr/bin/env bash

# Configuring locales
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=es_ES.UTF-8 > /etc/locale.conf
export LANG=es_ES.UTF-8

# Virtual console keymap
echo KEYMAP=es > /etc/vconsole.conf

# Change localtime
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

# Hostname
echo link-gl63-8rc > /etc/hostname

# Root password
clear
echo "Enter root password"
until passwd
do
	echo "Enter the password correctly"
done

# Restricting root login
sed -i "/pam_wheel.so use_uid/ s/^#//g" /etc/pam.d/su
sed -i "/pam_wheel.so use_uid/ s/^#//g" /etc/pam.d/su-l

# sudo config
EDITOR=vim visudo

# Enabling colors in pacman
sed -i "s/#Color/Color/g" /etc/pacman.conf

# Enabling multilib repo
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu --noconfirm

# Configuring mkinitcpio
pacman -S --noconfirm --needed lvm2
sed -i "s/udev autodetect modconf block filesystems/udev autodetect modconf block lvm2 encrypt filesystems/g" /etc/mkinitcpio.conf
sed -i "s/MODULES=()/MODULES=(i915)/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Install and configure systemd-boot
pacman -S --noconfirm --needed efibootmgr
bootctl install
mkdir -p /boot/loader/entries
cat > /boot/loader/loader.conf <<EOF
default  arch.conf
console-mode max
editor   no
EOF
cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux-hardened
initrd  /intel-ucode.img
initrd  /initramfs-linux-hardened.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/nvme0n1p2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_idle.max_cstate=1 splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
cat > /boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux Fallback
linux   /vmlinuz-linux-hardened
initrd  /intel-ucode.img
initrd  /initramfs-linux-hardened-fallback.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/nvme0n1p2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_idle.max_cstate=1 splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
bootctl update


#!/bin/bash

# Changing locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

# Setting default locale
echo LANG=es_ES.UTF-8 | tee /etc/locale.conf
export LANG=es_ES.UTF-8

# Changing timezone
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

# Setting default keymap for tty
echo KEYMAP=es | tee /etc/vconsole.conf

# Setting hostname
echo link-gl63-8rc | tee /etc/hostname

# Adding mkinitcpio HOOKS
sed -i 's/block filesystem/block encrypt lvm2 filesystem/g' /etc/mkinitcpio.conf
mkinitcpio -P

# Changing root password
clear
echo "Change root password"
passwd

# Adding user link and changing password
useradd -m -g users -G wheel link
clear
echo "Change link password"
passwd link

# Editing sudoers file
EDITOR=vim visudo

# Changing grub settings
sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=\/dev\/nvme0n1p2:luks:allow-discards\"/g" /etc/default/grub
sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g" /etc/default/grub

# Installing grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Adding multilib repos
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu

# Installing video drivers
pacman -S xf86-video-intel vulkan-intel lib32-mesa nvidia-dkms nvidia-prime lib32-nvidia-utils

# Installing required packages

pacman -S zsh zsh-syntax-highlighting jdk-openjdk vim mpv rhythmbox dolphin-emu msr-tools flatpak steam noto-fonts-cjk noto-fonts-emoji papirus-icon-theme telegram-desktop discord lutris emacs retroarch libretro-parallel-n64

# Editing /etc/makepkg.conf to use all CPU cores

cores=$(grep -c ^processor /proc/cpuinfo)
sed -i "s/#MAKEFLAGS=\"-j2\".*/MAKEFLAGS=\"-j$cores\"/" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -).*/COMPRESSXZ=(xz -c -z - --threads=$cores)/" /etc/makepkg.conf

# Editing /etc/pulse/daemon.conf to improve audio

sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf

# Executing archdi
curl -L archdi.sf.net/archdi > archdi
sh archdi
rm archdi

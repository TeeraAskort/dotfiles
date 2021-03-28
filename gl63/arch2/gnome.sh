#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Running base-system.sh
bash $directory/base-system.sh

# Install GNOME
pacman -S --noconfirm gnome gnome-tweaks gnome-nettool gnome-mahjongg aisleriot bubblewrap-suid gnome-software-packagekit-plugin ffmpegthumbnailer chrome-gnome-shell gtk-engine-murrine evolution tilix gnome-boxes transmission-gtk

# Removing unwanted packages
pacman -Rns --noconfirm gnome-music epiphany totem

# Installing plymouth
sudo -u aurbuilder paru -S gdm-plymouth plymouth-theme-hexagon-2-git

# Making lone theme default
plymouth-set-default-theme -R hexagon_2

# Configuring mkinitcpio
sed -i "s/udev autodetect/udev plymouth autodetect/g" /etc/mkinitcpio.conf
sed -i "s/encrypt/plymouth-encrypt/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Enabling GDM
systemctl enable gdm

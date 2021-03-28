#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Running base-system.sh
bash $directory/base-system.sh gdm-plymouth

# Install GNOME
pacman -S gnome gnome-tweaks gnome-nettool gnome-mahjongg aisleriot bubblewrap-suid gnome-software-packagekit-plugin ffmpegthumbnailer chrome-gnome-shell gtk-engine-murrine evolution tilix gnome-boxes transmission-gtk

# Removing unwanted packages
pacman -Rns --noconfirm gnome-music epiphany totem

# Enabling GDM
systemctl enable gdm

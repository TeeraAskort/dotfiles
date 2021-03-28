#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Running base-system.sh
bash $directory/base-system.sh

# Install Plasma
pacman -S --noconfirm plasma ark dolphin dolphin-plugins gwenview ffmpegthumbs filelight kdeconnect sshfs kdialog kio-extras kio-gdrive kmahjongg palapeli kpatience okular yakuake kcm-wacomtablet konsole spectacle kcalc kate kdegraphics-thumbnailers kcron ksystemlog kgpg kcharselect kdenetwork-filesharing audiocd-kio packagekit-qt5 gtk-engine-murrine kwallet-pam kwalletmanager kfind kwrite print-manager zeroconf-ioslave signon-kwallet-extension qbittorrent thunderbird thunderbird-i18n-es-es virt-manager

# Installing plymouth
sudo -u aurbuilder paru -S plymouth plymouth-theme-hexagon-2-git

# Making lone theme default
plymouth-set-default-theme -R hexagon_2

# Configuring mkinitcpio
pacman -S --noconfirm --needed lvm2
sed -i "s/udev autodetect modconf block filesystems/udev plymouth autodetect modconf block plymouth-encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
sed -i "s/MODULES=()/MODULES=(i915)/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Enabling SDDM
systemctl enable sddm-plymouth

# Removing unwanted Plasma apps
pacman -Rnc --noconfirm oxygen

# Adding environment variable to /etc/environment
echo "GTK_USE_PORTAL=1" | tee -a /etc/environment


#!/bin/bash

# Adding repos
curl -L "https://copr.fedorainfracloud.org/coprs/dawid/better_fonts/repo/fedora-33/dawid-better_fonts-fedora-33.repo" > better_fonts.repo
curl -L "https://copr.fedorainfracloud.org/coprs/alderaeney/plata-theme-master/repo/fedora-33/alderaeney-plata-theme-master-fedora-33.repo" > plata-theme-master.repo
cp better_fonts.repo plata-theme-master.repo /etc/yum.repos.d/

# Update system
rpm-ostree upgrade

# Add kinoite repo
curl -O https://tim.siosm.fr/assets/siosm.gpg
ostree remote add kinoite https://siosm.fr/kinoite/ --gpg-import siosm.gpg

# Rebase to kinoite
rpm-ostree rebase kinoite:fedora/33/x86_64/kinoite

# Add kdeapps flatpak repo
flatpak remote-add --if-not-exists kdeapps --from https://distribute.kde.org/kdeapps.flatpakrepo

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install apps
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks tilix intel-undervolt strawberry fontconfig-font-replacements fontconfig-enhanced-defaults openssl papirus-icon-theme

# Installing flatpak apps
flatpak install flathub org.telegram.desktop com.discordapp.Discord org.DolphinEmu.dolphin-emu com.nextcloud.desktopclient.nextcloud org.qbittorrent.qBittorrent org.libreoffice.LibreOffice com.valvesoftware.Steam com.github.Eloston.UngoogledChromium org.freedesktop.Piper com.github.micahflee.torbrowser-launcher com.google.AndroidStudio com.vscodium.codium org.gnome.Evolution org.jdownloader.JDownloader org.gimp.GIMP io.lbry.lbry-app com.mojang.Minecraft

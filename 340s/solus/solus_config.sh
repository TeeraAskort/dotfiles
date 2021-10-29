#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Updating the system
eopkg up -y

## Install drivers
eopkg it -y libva-intel-driver libva-vdpau-driver gstreamer-vaapi

# Installing required applications
eopkg it -y wine wine-devel wine-32bit winetricks flatpak vim zsh zsh-autosuggestions zsh-syntax-highlighting strawberry neovim python-neovim nodejs libfido2 pam-u2f gimp vscode telegram discord ntfs-3g exfatprogs unrar zip unzip openjdk-11-devel gamemode gamemode-32bit hplip lbry-desktop obs-studio pcsx2 thermald btrfs-progs cups noto-sans-ttf aisleriot gnome-mahjongg transmission xdg-desktop-portal-gtk evolution libgepub brasero p7zip dbeaver neofetch ffmpegthumbnailer virtualbox filezilla mariadb-server f2fs-tools cryptsetup curl hunspell-en hunspell-es php composer httpd

# Enabling services
systemctl enable mariadb thermald cups httpd

# Starting services
systemctl start mariadb

# Removing unwanted applications
eopkg rm -y hexchat rhythmbox thunderbird

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install -y flathub org.jdownloader.JDownloader com.getpostman.Postman com.jetbrains.PhpStorm org.chromium.Chromium com.axosoft.GitKraken com.mojang.Minecraft

# Configuring apache
mkdir -p /etc/httpd/conf.d/
cp $directory/php.conf /etc/httpd/conf.d/
systemctl restart httpd && systemctl restart php-fpm

# Copying php project
cd /var/www
git clone https://TeeraAskort@github.com/TeeraAskort/projecte-php.git
chown -R link:users projecte-php
chmod -R 755 projecte-php

# Overriding phpstorm config
user="$SUDO_USER"
sudo -u $user flatpak override --user --filesystem=/var/www/projecte-php com.jetbrains.PhpStorm

# Installing eclipse
curl -L "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2021-09/R/eclipse-jee-2021-09-R-linux-gtk-x86_64.tar.gz" > eclipse-jee.tar.gz
tar xzvf eclipse-jee.tar.gz -C /opt
rm eclipse-jee.tar.gz
desktop-file-install $directory/../common/eclipse.desktop

## Putting sysctl options
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Setting logind.conf hibernate settings
echo "HandleLidSwitch=hibernate" | tee -a /etc/systemd/logind.conf
echo "HandleLidSwitchExternalPower=hibernate" | tee -a /etc/systemd/logind.conf
echo "HandleLidSwitchDocked=hibernate" | tee -a /etc/systemd/logind.conf
echo "IdleAction=hibernate" | tee -a /etc/systemd/logind.conf
echo "IdleActionSec=15min" | tee -a /etc/systemd/logind.conf

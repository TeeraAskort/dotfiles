#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Updating the system
swupd update

# Installing basic packages
swupd bundle-add httpd php-extras database-basic lutris games vim neovim mpv zsh java-basic earlyoom flatpak nodejs-basic kernel-native-dkms wine zip storage-utils unzip 


# Installing flatpak applications
flatpak install flathub -y io.lbry.lbry-app org.jdownloader.JDownloader com.github.AmatCoder.mednaffe org.telegram.desktop com.axosoft.GitKraken com.getpostman.Postman io.dbeaver.DBeaverCommunity com.jetbrains.PhpStorm net.pcsx2.PCSX2 org.desmume.DeSmuME org.strawberrymusicplayer.strawberry com.visualstudio.code com.discordapp.Discord org.filezillaproject.Filezilla com.mojang.Minecraft org.chromium.Chromium

# Copying php project
cd /var/www/
git clone https://TeeraAskort@github.com/TeeraAskort/projecte-php.git
chown -R link:users projecte-php
chmod -R 755 projecte-php
cd $directory

# Overriding phpstorm config
user="$SUDO_USER"
sudo -u $user flatpak override --user --filesystem=/var/www/ com.jetbrains.PhpStorm

# Install virtualbox
curl -L "https://download.virtualbox.org/virtualbox/6.1.28/VirtualBox-6.1.28-147628-Linux_amd64.run" > virtualbox.run
./virtualbox.run
/sbin/vboxconfig

# Installing eclipse
curl -L "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2021-09/R/eclipse-jee-2021-09-R-linux-gtk-x86_64.tar.gz" > eclipse-jee.tar.gz
tar xzvf eclipse-jee.tar.gz -C /opt
rm eclipse-jee.tar.gz
desktop-file-install $directory/../common/eclipse.desktop


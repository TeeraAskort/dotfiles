#!/usr/bin/env bash

# Updating the system
eopkg up -y

# Installing required applications
eopkg it -y wine wine-devel wine-32bit winetricks flatpak vim zsh strawberry steam lutris 

# Removing unwanted applications
eopkg rm -y 

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install -y flathub org.jdownloader.JDownloader com.getpostman.Postman org.telegram.desktop com.discordapp.Discord com.jetbrains.PhpStorm




# Installing xampp
ver="8.0.12"
until curl -L "https://www.apachefriends.org/xampp-files/${ver}/xampp-linux-x64-${ver}-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts

# Copying php project
cd /opt/lampp/htdocs
git clone https://TeeraAskort@github.com/TeeraAskort/projecte-php.git
chown -R link:users projecte-php
chmod -R 755 projecte-php

# Overriding phpstorm config
user="$SUDO_USER"
sudo -u $user flatpak override --user --filesystem=/opt/lampp/htdocs com.jetbrains.PhpStorm

# Installing eclipse
curl -L "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2021-09/R/eclipse-jee-2021-09-R-linux-gtk-x86_64.tar.gz" > eclipse-jee.tar.gz
tar xzvf eclipse-jee.tar.gz -C /opt
rm eclipse-jee.tar.gz
desktop-file-install $directory/../common/eclipse.desktop

#!/usr/bin/env bash

## Updating the system
eopkg up

## Installing required applications
eopkg it thermald intel-undervolt vim zsh zsh-autosuggestions zsh-syntax-highlighting tilix openjdk-11-devel telegram flatpak tlp transmission strawberry gimp pam-u2f libfido2 steam lutris wine wine-devel wine-32bit-devel winetricks piper gnome-mahjongg aisleriot nodejs neovim python-neovim cmake vscode python-devel g++ discord lbry-desktop 

## Enabling services
systemctl enable tlp intel-undervolt thermald

## Removing unwanted apps
eopkg rm rhythmbox hexchat 

## Editing intel-undervolt settings
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

## Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Installing required flatpak apps
flatpak install -y flathub com.mojang.Minecraft com.google.AndroidStudio com.github.micahflee.torbrowser-launcher org.jdownloader.JDownloader org.gimp.GIMP com.tutanota.Tutanota com.obsproject.Studio com.getpostman.Postman com.jetbrains.IntelliJ-IDEA-Community com.bitwarden.desktop 

## Add sysctl config
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing XAMPP
version="8.0.2"
subver="0"
curl -L "https://www.apachefriends.org/xampp-files/${version}/xampp-linux-x64-${version}-${subver}-installer.run" > xampp.run
chmod +x xampp.run
./xampp.run --mode unattended --unattendedmodeui minimal
rm xampp.run



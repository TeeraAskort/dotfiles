#!/usr/bin/env bash

## Updating the system
eopkg up

## Installing required applications
eopkg it thermald intel-undervolt vim zsh zsh-autosuggestions zsh-syntax-highlighting tilix openjdk-11-devel telegram flatpak tlp transmission strawberry gimp pam-u2f libfido2 steam lutris wine wine-devel wine-32bit winetricks piper gnome-mahjongg aisleriot nodejs neovim python-neovim cmake vscode python-devel g++ discord lbry-desktop 

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
flatpak install -y flathub com.mojang.Minecraft com.google.AndroidStudio com.github.micahflee.torbrowser-launcher org.jdownloader.JDownloader org.gimp.GIMP com.tutanota.Tutanota com.obsproject.Studio com.getpostman.Postman com.jetbrains.IntelliJ-IDEA-Community com.bitwarden.desktop com.anydesk.Anydesk com.slack.Slack io.dbeaver.DBeaverCommunity 

## Add sysctl config
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing ionic
npm i -g @ionic/cli

# Installing Google Chrome
eopkg bi --ignore-safety https://raw.githubusercontent.com/getsolus/3rd-party/master/network/web/browser/google-chrome-stable/pspec.xml
eopkg it google-chrome-*.eopkg;sudo rm google-chrome-*.eopkg

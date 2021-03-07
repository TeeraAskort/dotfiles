#!/bin/env bash

## Enabling 32bit support
sudo dpkg --add-architecture i386

## Add PPA repositories
sudo add-apt-repository ppa:jonaski/strawberry -y
sudo add-apt-repository ppa:papirus/papirus -y
sudo add-apt-repository ppa:kisak/kisak-mesa -y

## Updating the system
sudo apt update 
sudo apt full-upgrade -y

## Installing required applications
sudo apt install -y zsh zsh-syntax-highlighting zsh-autosuggestions mpv telegram-desktop curl strawberry libglu1-mesa xz-utils vim tilix openjdk-11-jdk libfido2-1 pamu2fcfg nodejs npm thermald build-essential neovim python3-neovim papirus-icon-theme tlp piper flatpak net-tools libnsl2 fonts-noto-cjk fonts-noto-color-emoji hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us libreoffice libreoffice-l10n-es gimp mednafen mednaffe dolphin-emu chromium-browser libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 cmake python3-dev libpam-u2f

## Installing DE specific applications
if [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
	
	## Installing packages
	sudo apt install -y aisleriot gnome-mahjongg transmission-gtk ffmpegthumbnailer evolution gnome-tweaks


elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
	echo "TODO"
fi

## Install outsider applications
curl -L "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > code.deb
curl -LO "https://lbry.com/get/lbry.deb"
curl -LO "https://launcher.mojang.com/download/Minecraft.deb"
sudo apt install -y ./discord.deb ./steam.deb ./code.deb ./lbry.deb ./Minecraft.deb

## Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/' -y
sudo apt update
sudo apt install --install-recommends -y winehq-staging
sudo apt install -y winetricks

## Install flutter SDK
sudo snap install flutter --classic

## Add sysctl config
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.d/99-sysctl.conf

## Installing angular globally
sudo npm i -g @angular/cli
sudo ng analytics off

## Installing XAMPP
version="8.0.2"
subver="0"
curl -L "https://www.apachefriends.org/xampp-files/${version}/xampp-linux-x64-${version}-${subver}-installer.run" > xampp.run
chmod +x xampp.run
sudo ./xampp.run --mode unattended --unattendedmodeui minimal

## Removing unused packages
sudo apt autoremove --purge -y

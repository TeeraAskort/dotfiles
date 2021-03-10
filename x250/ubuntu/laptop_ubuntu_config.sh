#!/bin/env bash

## Enabling 32bit support
sudo dpkg --add-architecture i386

## Add PPA repositories
sudo add-apt-repository ppa:jonaski/strawberry -y
sudo add-apt-repository ppa:papirus/papirus -y
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo add-apt-repository ppa:lutris-team/lutris -y
sudo add-apt-repository ppa:nextcloud-devs/client -y
sudo add-apt-repository ppa:maarten-fonville/android-studio -y

## Updating the system
sudo apt update 
sudo apt full-upgrade -y

## Installing required applications
sudo apt install -y zsh zsh-syntax-highlighting zsh-autosuggestions mpv telegram-desktop curl strawberry libglu1-mesa xz-utils vim tilix openjdk-11-jdk libfido2-1 pamu2fcfg nodejs npm thermald build-essential neovim python3-neovim papirus-icon-theme tlp piper flatpak net-tools libnsl2 fonts-noto-cjk fonts-noto-color-emoji hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us libreoffice libreoffice-l10n-es gimp mednafen mednaffe dolphin-emu libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 cmake python3-dev libpam-u2f lutris gamemode nextcloud-desktop network-manager-l2tp-gnome flatpak gnome-software-plugin-flatpak mariadb-server qemu-kvm libvirt0 android-studio-4.1 

## Installing DE specific applications
if [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
	
	## Installing packages
	sudo apt install -y aisleriot gnome-mahjongg transmission-gtk ffmpegthumbnailer evolution gnome-tweaks qt5-style-plugins

	## Linking vte.sh
	sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

	## Adding environment variable
	echo "QT_QPA_PLATFORMTHEME=gtk2" | sudo tee -a /etc/environment

elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
	echo "TODO"
fi

## Install anydesk
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
sudo apt update
sudo apt install -y anydesk

## Install outsider applications
until curl -L "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
do 
	echo "retrying"
done

until curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
do
	echo "retrying"
done

until curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > code.deb
do
	echo "retrying"
done

until curl -LO "https://lbry.com/get/lbry.deb"
do
	echo "retrying"
done

until curl -LO "https://launcher.mojang.com/download/Minecraft.deb"
do
	echo "retrying"
done
sudo apt install -y ./discord.deb ./steam.deb ./code.deb ./lbry.deb ./Minecraft.deb

## Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/' -y
sudo apt update
sudo apt install --install-recommends -y winehq-staging
sudo apt install -y winetricks

## Install flatpak applications 
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub -y org.jdownloader.JDownloader com.tutanota.Tutanota com.obsproject.Studio com.getpostman.Postman com.jetbrains.IntelliJ-IDEA-Community com.bitwarden.desktop com.slack.Slack com.axosoft.GitKraken org.chromium.Chromium

## Installing snap applications
sudo snap install flutter --classic

## Add sysctl config
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.d/99-sysctl.conf

## Installing angular globally
sudo npm i -g @angular/cli
sudo ng analytics off

## Adding user to kvm group
user=$USER
sudo usermod -aG kvm $user

## Removing unused packages
sudo apt autoremove --purge -y

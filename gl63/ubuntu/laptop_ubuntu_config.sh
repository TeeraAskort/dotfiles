#!/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

## Enabling 32bit support
sudo dpkg --add-architecture i386

## Add PPA repositories
sudo add-apt-repository ppa:jonaski/strawberry -y
sudo add-apt-repository ppa:papirus/papirus -y
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo add-apt-repository ppa:lutris-team/lutris -y
sudo add-apt-repository ppa:nextcloud-devs/client -y
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo add-apt-repository multiverse -y

## Updating the system
sudo apt update 
sudo apt full-upgrade -y

## Installing required applications
sudo apt install -y zsh zsh-syntax-highlighting zsh-autosuggestions mpv telegram-desktop curl strawberry libglu1-mesa xz-utils vim tilix openjdk-11-jdk libfido2-1 pamu2fcfg nodejs npm thermald build-essential neovim python3-neovim papirus-icon-theme tlp piper flatpak net-tools libnsl2 fonts-noto-cjk fonts-noto-color-emoji hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us libreoffice libreoffice-l10n-es gimp mednafen mednaffe dolphin-emu chromium-browser libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 cmake python3-dev libpam-u2f lutris gamemode nextcloud-desktop network-manager-l2tp-gnome nvidia-driver-450 libvulkan1 libvulkan1:i386 ubuntu-restricted-extras

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

## Installing snap applications
sudo snap install intellij-idea-community --classic
sudo snap install android-studio --classic
sudo snap install slack --classic
sudo snap install flutter --classic
sudo snap install bitwarden

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

## Update grub
sudo sed -i "s/GRUB_CMDLINE_LINUX=\"\(.*\)\"/GRUB_CMDLINE_LINUX=\"\1 intel_idle.max_cstate=1 \"/" /etc/default/grub
sudo update-grub

## Copying prime-run
sudo cp $directory/../dotfiles/prime-run /usr/bin/prime-run
sudo chmod +x /usr/bin/prime-run

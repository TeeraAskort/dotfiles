#!/usr/bin/env bash

if [ "$1" == "gnome" ] || [ "$1" == "budgie" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then 
	## Update the system
	eopkg up
	
	## Install chrome
	eopkg bi -y --ignore-safety https://raw.githubusercontent.com/getsolus/3rd-party/master/network/web/browser/google-chrome-stable/pspec.xml
	eopkg it -y google-chrome-*.eopkg;  rm google-chrome-*.eopkg
	
	## Install android studio
	eopkg bi -y --ignore-safety https://raw.githubusercontent.com/getsolus/3rd-party/master/programming/android-studio/pspec.xml
	eopkg it -y android-studio*.eopkg; rm android-studio*.eopkg
	
	## Install global packages
	eopkg it -y strawberry nodejs vim neovim python-neovim wine wine-devel winetricks zsh zsh-syntax-highlighting zsh-autosuggestions steam lutris gimp vscode telegram discord dolphin-emu thermald gamemode gamemode-32bit youtube-dl openjdk-11-devel btrfs-progs ntfs-3g p7zip unrar exfatprogs hplip cups pcsx2 noto-sans-ttf flatpak obs-studio lbry-desktop 
	
	## Enabling services
	systemctl enable thermald
	
	if [ "$1" == "budgie" ] || [ "$1" == "gnome" ]; then
		## Installing desktop specific packages
		eopkg it -y gnome-mahjongg aisleriot brasero ffmpegthumbnailer transmission xdg-desktop-portal-gtk gnome-boxes evolution libgepub 
		
		## Removing unwanted applications
		eopkg rm -y hexchat rhythmbox thunderbird
	fi
	
	if [ "$1" == "gnome" ]; then
		## Installing gnome specific packages
		eopkg it -y chrome-gnome-shell materia-gtk-theme-dark-compact
	fi

    	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
        	## Installing desktop specific applications
        	eopkg it -y palapeli kmahjongg kpat qbittorrent mpv yakuake gnome-keyring xdg-desktop-portal-kde plasma-browser-integration virt-manager ffmpegthumbs k3b kio-extras wacomtablet qemu libvirt

        	## Removing unwanted applications
        	eopkg rm -y konversation elisa smplayer
	fi

	## Adding flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	## Installing flatpak applications
	flatpak install -y flathub org.jdownloader.JDownloader com.katawa_shoujo.KatawaShoujo org.desmume.DeSmuME org.flarerpg.Flare com.mojang.Minecraft
	
	## Installing npm packages globally
	npm i -g @ionic/cli @vue/cli 
	
	## Adding kernel parameters
	echo "intel_idle.max_cstate=1" | tee -a /etc/kernel/cmdline
	clr-boot-manager update
	
else
	echo "Available options:"
	echo "gnome - To install gnome config"
	echo "budgie - To install budgie config"
	echo "kde / plasma - To install plasma config"
fi 

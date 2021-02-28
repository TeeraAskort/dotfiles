#!/bin/bash

if [ "$1" = "gnome" ] || [ "$1" = "kde" ] || [ "$1" = "plasma" ]; then

	## Getting the user
	user=$SUDO_USER

	## Enabling i386 support
	dpkg --add-architecture i386
	apt update

	## Installing needed packages for getting third party repos
	apt install -y curl wget apt-transport-https dirmngr

	## Adding third party repos
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list
	echo "deb [arch=i386,amd64] http://repo.steampowered.com/steam/ precise steam" | tee /etc/apt/sources.list.d/steam.list
	echo "deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/faudio.list
	echo "deb http://deb.debian.org/debian buster-backports main contrib nonfree" | tee -a /etc/apt/sources.list

	## Importing third party repos keys
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F24AEA9FB05498B7
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
	curl -LO "https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key" && apt-key add Release.key

	## Adding deb-multimedia repo
	echo "deb http://www.deb-multimedia.org buster main non-free" | tee /etc/apt/sources.list.d/deb-multimedia.list
	apt-get update -oAcquire::AllowInsecureRepositories=true
	apt-get install deb-multimedia-keyring

	## Updating the system
	apt update -y

	## Upgrading the system
	apt full-upgrade -y

	## Installing basic packages
	apt install -y mpv flatpak mednafen mednaffe vim papirus-icon-theme zsh zsh-syntax-highlighting zsh-autosuggestions firmware-linux steam telegram-desktop neovim fonts-noto-cjk openjdk-11-jdk thermald intel-microcode gamemode hyphen-en-us mythes-en-us sqlitebrowser net-tools tlp wget apt-transport-https gnupg python3-dev cmake nodejs npm chromium code libpam-u2f pamu2fcfg libfido2-1 hunspell-es hunspell-en-us dolphin-emu libreoffice firefox-esr gimp w64codecs gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio gstreamer1.0-qt5 gstreamer1.0-vaapi gstreamer1.0-libav youtube-dl earlyoom apparmor apparmor-utils apparmor-profiles-extra apparmor-profiles apparmor-notify cups hp-ppd hplip firewalld python-neovim

	## Adding the user to the adm group
	usermod -aG adm $user 

	if [ "$1" = "gnome" ]; then
		echo "uninplemented"
	elif [ "$1" = "kde" ] || [ "$1" = "plasma" ]; then
		## Installing plasma desktop
		apt install -y kde-plasma-desktop breeze-gtk-theme kde-config-gtk-style kde-config-gtk-style-preview kde-config-sddm sddm-theme-debian-breeze kde-config-tablet kde-config-screenlocker kde-config-plymouth libreoffice-kde5 okular ffmpegthumbs gwenview qbittorrent kpat palapeli kmahjongg bluedevil yakuake thunderbird kde-spectacle okular-backend-odt okular-backend-odp okular-extra-backends okular-mobile kcalc ksysguard filelight kdenetwork-filesharing kgpg kate ark dolphin-plugins kdeconnect plasma-discover plasma-discover-backend-flatpak plasma-discover-backend-fwupd plasma-discover-backend-snap kcharselect print-manager skanlite 

		## Removing unwanted applications
		apt remove -y --purge konqueror
		 
		## Adding environment variable to /etc/environment
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment
	fi

	## Installing lutris
	echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
	wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | apt-key add -
	apt-get update
	apt-get install -y lutris

	## Installing wine
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	apt-key add winehq.key
	echo "deb https://dl.winehq.org/wine-builds/debian/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list
	apt update && sudo apt install -y winehq-staging winetricks

	## Installing outsider packages
	version="0.8.5"
	curl -L "https://files.strawberrymusicplayer.org/strawberry_${version}-buster_amd64.deb" > strawberry.deb
	apt install -y ./strawberry.deb

	## Installing flatpak applications
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install -y flathub com.discordapp.Discord com.github.micahflee.torbrowser-launcher io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio com.bitwarden.desktop com.google.AndroidStudio com.jetbrains.IntelliJ-IDEA-Community

	## Adding grub parameters
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash apparmor=1 security=apparmor"/' /etc/default/grub
	sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1366x768x32/g' /etc/default/grub
	update-grub

	## Setting hexagon_2 plymouth theme
	curl -LO "https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz"
	tar xzvf hexagon_2.tar.gz
	mv -r hexagon_2 /usr/share/plymouth/themes
	plymouth-set-default-theme -R hexagon_2

	## Removing unused packages
	apt autoremove --purge -y

	## Add sysctl config
	echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.d/99-sysctl.conf
	echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf

	## Installing angular globally
	npm i -g @angular/cli
	ng analytics off

	## Installing XAMPP
	version="8.0.2"
	subver="0"
	curl -L "https://www.apachefriends.org/xampp-files/${version}/xampp-linux-x64-${version}-${subver}-installer.run" > xampp.run
	chmod +x xampp.run
	./xampp.run --mode unattended --unattendedmodeui minimal

else
	echo "Debian stable installer: "	
	echo "gnome - To install the gnome desktop"
	echo "kde or plasma - To install plasma desktop"
fi

#!/usr/bin/env bash

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "xfce" ]; then
	user=$SUDO_USER

	# Adding 32bit support
	dpkg --add-architecture i386
	apt update

	# Installing curl
	apt install -y curl wget

	# Installing drivers
	apt install -y libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 firmware-linux-nonfree firmware-misc-nonfree

	# Adding vivaldi repo
	# wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | apt-key add -
	# add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main' 
	# apt update
       	# apt install -y vivaldi-stable
	# apt remove -y firefox-esr
	
	# Installing strawberry
	curl -s https://api.github.com/repos/strawberrymusicplayer/strawberry/releases/latest \
	| grep "browser_download_url" \
	| grep "strawberry_" \
	| grep "bullseye" \
	| cut -d '"' -f 4 \
	| wget -O strawberry.deb -qi -
	apt install -y ./strawberry.deb
	
	# Installing wine
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	apt-key add winehq.key
	echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" | tee /etc/apt/sources.list.d/wine.list
	apt update
       	apt install -y winehq-staging winetricks

	# Installing VSCode
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
	echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
	rm -f packages.microsoft.gpg
	apt install apt-transport-https && apt update
	apt install -y code
	
	# Add deb-multimedia repo
	echo "deb https://www.deb-multimedia.org bullseye main non-free" | tee /etc/apt/sources.list.d/multimedia.list
	apt-get update -oAcquire::AllowInsecureRepositories=true
	apt install deb-multimedia-keyring --allow-unauthenticated
	apt update
       	apt full-upgrade -y

	# Installing lutris
	echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
	wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | sudo apt-key add -
	apt update
       	apt install -y lutris

	# Installing required applications
	apt install -y build-essential steam vim nano fonts-noto fonts-noto-cjk fonts-noto-mono pcsx2 mednafen mednaffe telegram-desktop nodejs npm neovim python3-neovim gimp flatpak papirus-icon-theme zsh zsh-autosuggestions zsh-syntax-highlighting thermald mpv youtube-dl chromium libreoffice firmware-linux libfido2-1 gamemode hyphen-en-us mythes-en-us pamu2fcfg libpam-u2f btrfs-progs gparted ntfs-3g exfat-utils f2fs-tools unrar hplip printer-driver-cups-pdf earlyoom obs-studio gstreamer1.0-vaapi desmume
	
	systemctl enable thermald
	
	if [ "$1" == "gnome" ]; then
		# Installing required packages
		apt install materia-gtk-theme qt5-qmake qtbase5-private-dev libgtk2.0-0 libx11-6 ffmpegthumbnailer tilix transmission-gtk evolution aisleriot gnome-mahjongg 
		
		# Installing qt5gtk2
		git clone https://bitbucket.org/trialuser02/qt5gtk2.git
		cd qt5gtk2
		qmake && make && make install
		cd .. && rm -r qt5gtk2
		echo "QT_QPA_PLATFORMTHEME=qt5gtk2" | tee -a /etc/environment
		
		# Remove unwanted applications
		apt remove -y totem rhythmbox 
		
	elif [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		# Installing required packages
		apt install -y qbittorrent palapeli kmahjongg kpat thunderbird thunderbird-l10n-es-es yakuake gnome-keyring libpam-gnome-keyring libpam-kwallet5 sddm-theme-breeze kdeconnect nautilus-kdeconnect plasma-browser-integration qemu-system libvirt-clients libvirt-daemon-system virt-manager xdg-desktop-portal-kde ffmpegthumbs kde-config-tablet dolphin-plugins k3b kio-audiocd

		# Adding user to libvirt group
		adduser $user libvirt
		
		# Remove unwanted applications
		apt remove -y konversation akregator kmail konqueror dragonplayer juk kaddressbook korganizer

		# Adding environment variable
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment
		
	elif [ "$1" == "xfce" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends thunderbird materia-gtk-theme qt5-qmake qtbase5-private-dev libgtk2.0-0 libx11-6 ffmpegthumbnailer tumbler tumbler-plugins-extra transmission-gtk
		
		# Installing qt5gtk2
		git clone https://bitbucket.org/trialuser02/qt5gtk2.git
		cd qt5gtk2
		qmake && make && make install
		cd .. && rm -r qt5gtk2
		echo "QT_QPA_PLATFORMTHEME=qt5gtk2" | tee -a /etc/environment
	fi
	
	# Removing unused packages
	apt autoremove -y
	
	#Add flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	#Install flatpak applications
	flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app org.jdownloader.JDownloader org.DolphinEmu.dolphin-emu com.katawa_shoujo.KatawaShoujo

	# Installing angular globally
	npm i -g @angular/cli @ionic/cli @vue/cli firebase-tools
	ng analytics off

	# Updating grub
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
	sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
	update-grub

	# Setting hexagon_2 plymouth theme
	curl -LO "https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz"
	tar xzvf hexagon_2.tar.gz
	cp -r hexagon_2 /usr/share/plymouth/themes
	plymouth-set-default-theme -R hexagon_2

	# Putting sysctl options
	echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
	echo "xfce - to configure the XFCE desktop"
fi


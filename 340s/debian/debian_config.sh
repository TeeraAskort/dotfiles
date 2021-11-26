#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "xfce" ] || [ "$1" == "cinnamon" ] || [ "$1" == "mate" ]; then
	# Adding i386 support
	dpkg --add-architecture i386
	apt update

	# Installing curl
	apt install -y curl wget software-properties-common pkg-config

	# Adding backports and fasttrack repos
	echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" | tee -a /etc/apt/sources.list
	apt update
	apt install fasttrack-archive-keyring
	echo "deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-fasttrack main contrib" | tee -a /etc/apt/sources.list
	echo "deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-backports-staging main contrib" | tee -a /etc/apt/sources.list
	apt update

	# Installing drivers
	apt install -y libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 firmware-linux-nonfree firmware-misc-nonfree intel-microcode iucode-tool intel-media-va-driver-non-free mesa-va-drivers

	# Installing strawberry
	curl -s https://api.github.com/repos/strawberrymusicplayer/strawberry/releases/latest |
		grep "browser_download_url" |
		grep "strawberry_" |
		grep "bullseye" |
		cut -d '"' -f 4 |
		wget -O strawberry.deb -qi -
	apt install -y ./strawberry.deb
	rm strawberry.deb

	# Installing dbeaver
	wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | apt-key add -
	echo "deb https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
	apt-get update && apt-get install -y dbeaver-ce

	# Installing gitkraken
	curl -L "https://release.gitkraken.com/linux/gitkraken-amd64.deb" > $directory/gitkraken.deb
	apt install -y $directory/gitkraken.deb
	rm $directory/gitkraken.deb

	# Installing wine
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	apt-key add winehq.key
	echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" | tee /etc/apt/sources.list.d/wine.list
	apt update
	apt install -y winehq-staging winetricks
	rm winehq.key

	# Installing VSCode
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
	install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
	echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
	rm -f packages.microsoft.gpg
	apt install apt-transport-https && apt update
	apt install -y code

	# Add deb-multimedia repo
	echo "deb https://www.deb-multimedia.org $(lsb_release -cs) main non-free" | tee /etc/apt/sources.list.d/multimedia.list
	apt-get update -oAcquire::AllowInsecureRepositories=true
	apt install deb-multimedia-keyring --allow-unauthenticated
	apt update
	apt full-upgrade -y

	# Installing lutris
	echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
	wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | sudo apt-key add -
	apt update
	apt install -y lutris

	# Installing nodejs
	curl -fsSL https://deb.nodesource.com/setup_17.x | bash -
	apt-get install -y nodejs

	# Pre accepting licenses
	echo "steam steam/question select I AGREE" | debconf-set-selections
	echo steam steam/license note '' | debconf-set-selections
	echo "virtualbox-ext-pack virtualbox-ext-pack/license select true" | debconf-set-selections

	# Installing required packages
	apt install -y build-essential steam vim nano fonts-noto fonts-noto-cjk fonts-noto-mono mednafen mednaffe neovim python3-neovim gimp flatpak papirus-icon-theme zsh zsh-autosuggestions zsh-syntax-highlighting thermald mpv chromium libreoffice firmware-linux libfido2-1 gamemode hyphen-en-us mythes-en-us btrfs-progs gparted ntfs-3g exfat-utils f2fs-tools unrar hplip printer-driver-cups-pdf earlyoom obs-studio gstreamer1.0-vaapi desmume openjdk-11-jdk zip unzip filezilla virtualbox virtualbox-ext-pack wget yt-dlp pcsx2 cryptsetup ttf-mscorefonts-installer chromium

	# Enabling services
	systemctl enable thermald 

	# Installing computer specific software
	apt install -y pamu2fcfg libpam-u2f

	# Installing mpv-mpris
	curl -LO "https://github.com/hoyon/mpv-mpris/releases/latest/download/mpris.so"
	mkdir -p /etc/mpv/scripts
	mv mpris.so /etc/mpv/scripts/mpris.so

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
		apt install -y qbittorrent palapeli kmahjongg kpat thunderbird thunderbird-l10n-es-es yakuake gnome-keyring libpam-gnome-keyring libpam-kwallet5 sddm-theme-breeze kdeconnect plasma-browser-integration xdg-desktop-portal-kde ffmpegthumbs kde-config-tablet dolphin-plugins k3b kio-audiocd libreoffice-qt5 libreoffice-kf5 xdg-desktop-portal

		# Remove unwanted applications
		apt remove -y konversation akregator kmail konqueror dragonplayer juk kaddressbook korganizer vlc

		# Adding environment variable
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

		# Adding gnome-keyring settings
		awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/login /etc/pam.d/login >login
		if diff /etc/pam.d/login.bak login; then
			awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/login /etc/pam.d/login >login
			cp login /etc/pam.d/login
		else
			sudo cp login /etc/pam.d/login
		fi
		rm login
		awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/login /etc/pam.d/login >login
		if diff /etc/pam.d/login.bak login; then
			awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/login /etc/pam.d/login >login
			cp login /etc/pam.d/login
		else
			sudo cp login /etc/pam.d/login
		fi
		rm login
		echo "password	optional	pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

	elif [ "$1" == "xfce" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends thunderbird materia-gtk-theme qt5-qmake qtbase5-private-dev libgtk2.0-0 libx11-6 ffmpegthumbnailer tumbler tumbler-plugins-extra transmission-gtk

		# Installing qt5gtk2
		git clone https://bitbucket.org/trialuser02/qt5gtk2.git
		cd qt5gtk2
		qmake && make && make install
		cd .. && rm -r qt5gtk2
		echo "QT_QPA_PLATFORMTHEME=qt5gtk2" | tee -a /etc/environment

	elif [ "$1" == "cinnamon" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends materia-gtk-theme materia-kde qt5-style-kvantum transmission-gtk aisleriot gnome-mahjongg ffmpegthumbnailer lightdm-settings slick-greeter xdg-desktop-portal-gtk libpam-gnome-keyring libgepub-0.6-0 libgsf-1-114 libwebp6 libopenraw7 geary

		# Removing unwanted applications
		apt remove -y gnome-2048 gnome-taquin tali gnome-robots gnome-tetravex quadrapassel four-in-a-row five-or-more lightsoff gnome-chess hoichess gnome-klotski swell-foop gnome-mines gnome-nibbles iagno gnome-sudoku inkscape hexchat remmina pidgin rhythmbox sound-juicer totem vlc hitori termit shotwell synaptic thunderbird

		# Adding environment variable
		echo "QT_STYLE_OVERRIDE=kvantum" | tee -a /etc/environment

	elif [ "$1" == "mate" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends materia-gtk-theme materia-kde qt5-style-kvantum transmission-gtk aisleriot gnome-mahjongg ffmpegthumbnailer lightdm-settings slick-greeter xdg-desktop-portal-gtk libpam-gnome-keyring libgepub-0.6-0 libgsf-1-114 libwebp6 libopenraw7

		# Removing unwanted applications
		apt remove -y

		# Adding environment variable
		echo "QT_STYLE_OVERRIDE=kvantum" | tee -a /etc/environment

	fi

	# Updating grub
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_idle.max_cstate=1 splash"/' /etc/default/grub
	sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
	update-grub

	# Setting rings plymouth theme
	until wget https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_4/rings.tar.gz; do
		echo "Download failed, retrying"
	done
	tar xzvf rings.tar.gz
	mv rings /usr/share/plymouth/themes/
	plymouth-set-default-theme -R rings
	rm rings.tar.gz

	# Adding flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	
	# Installing flatpak applications
	flatpak install -y flathub org.jdownloader.JDownloader com.getpostman.Postman org.telegram.desktop com.discordapp.Discord com.jetbrains.PhpStorm 

	# Installing eclipse
	curl -L "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2021-09/R/eclipse-jee-2021-09-R-linux-gtk-x86_64.tar.gz" > eclipse-jee.tar.gz
	tar xzvf eclipse-jee.tar.gz -C /opt
	rm eclipse-jee.tar.gz
	desktop-file-install $directory/../common/eclipse.desktop

	# Removing uneeded packages
	apt autoremove --purge -y

fi

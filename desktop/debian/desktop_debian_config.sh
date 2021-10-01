#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "xfce" ] || [ "$1" == "cinnamon" ]; then
	user=$SUDO_USER

	# Adding 32bit support
	dpkg --add-architecture i386
	apt update

	# Installing curl
	apt install -y curl wget software-properties-common

	# Adding backports and fasttrack repos
	echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" | tee -a /etc/apt/sources.list
	apt update
	apt install fasttrack-archive-keyring
	echo "deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-fasttrack main contrib" | tee -a /etc/apt/sources.list
	echo "deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-backports-staging main contrib" | tee -a /etc/apt/sources.list
	apt update

	# Installing drivers
	apt install -y firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 mesa-va-drivers

	# Adding xanmod kernel
	echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list
	wget -qO - https://dl.xanmod.org/gpg.key | apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
	apt update
	apt install -y linux-xanmod intel-microcode iucode-tool
	echo 'net.core.default_qdisc = fq_pie' | tee /etc/sysctl.d/90-override.conf

	# Adding vivaldi repo
	# wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | apt-key add -
	# add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'
	# apt update
	# apt install -y vivaldi-stable
	# apt remove -y firefox-esr

	# Installing strawberry
	# curl -s https://api.github.com/repos/strawberrymusicplayer/strawberry/releases/latest |
	#	grep "browser_download_url" |
	#	grep "strawberry_" |
	#	grep "bullseye" |
	#	cut -d '"' -f 4 |
	#	wget -O strawberry.deb -qi -
	# apt install -y ./strawberry.deb

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

	# Installing minecraft
	curl -L "https://launcher.mojang.com/download/Minecraft.deb" > minecraft.deb
	apt install -y ./minecraft.deb
	rm minecraft.deb

	# Installing required applications
	apt install -y build-essential steam vim nano fonts-noto fonts-noto-cjk fonts-noto-mono pcsx2 mednafen mednaffe neovim python3-neovim gimp flatpak papirus-icon-theme zsh zsh-autosuggestions zsh-syntax-highlighting thermald mpv chromium libreoffice firmware-linux libfido2-1 gamemode hyphen-en-us mythes-en-us btrfs-progs gparted ntfs-3g exfat-utils f2fs-tools unrar hplip printer-driver-cups-pdf earlyoom obs-studio gstreamer1.0-vaapi desmume openjdk-11-jdk zip unzip nodejs npm php snapd filezilla virtualbox virtualbox-ext-pack clementine snapd composer wget net-tools yt-dlp

	systemctl enable thermald

	# Installing mpv-mpris
	apt install -y libmpv-dev libglib2.0-dev
	git clone https://github.com/hoyon/mpv-mpris.git
	cd mpv-mpris
	make 
	mkdir /etc/mpv/scripts
	cp mpris.so /etc/mpv/scripts
	cd .. && rm -r mpv-mpris
	apt remove -y libmpv-dev libglib2.0-dev

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
		apt install -y qbittorrent palapeli kmahjongg kpat thunderbird thunderbird-l10n-es-es yakuake gnome-keyring libpam-gnome-keyring libpam-kwallet5 sddm-theme-breeze kdeconnect plasma-browser-integration qemu-system libvirt-clients libvirt-daemon-system virt-manager xdg-desktop-portal-kde ffmpegthumbs kde-config-tablet dolphin-plugins k3b kio-audiocd libreoffice-qt5 libreoffice-kf5 xdg-desktop-portal

		# Adding user to libvirt group
		adduser $user libvirt

		# Remove unwanted applications
		apt remove -y konversation akregator kmail konqueror dragonplayer juk kaddressbook korganizer xdg-desktop-portal-gtk vlc

		# Adding environment variable
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

		# Adding gnome-keyring settings
		cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
		awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm
		cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
		awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm

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
	fi

	# Removing unused packages
	apt autoremove -y

	#Add flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	#Install flatpak applications
	flatpak install -y flathub com.discordapp.Discord org.jdownloader.JDownloader org.DolphinEmu.dolphin-emu com.google.AndroidStudio io.lbry.lbry-app com.getpostman.Postman org.eclipse.Java org.telegram.desktop

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

	# Installing xampp
	ver="8.0.11"
	curl -L "https://www.apachefriends.org/xampp-files/${ver}/xampp-linux-x64-${ver}-0-installer.run" >xampp.run
	chmod 755 xampp.run
	./xampp.run --unattendedmodeui minimal --mode unattended
	rm xampp.run

	# Setting hostname properly for xampp
	echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts

	# Installing lxd from snap store
	systemctl restart snapd.socket
	until snap install lxd; do
		echo "Waiting for lxd to install"
		sleep 10;
	done
else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
	echo "xfce - to configure the XFCE desktop"
fi

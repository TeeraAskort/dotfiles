#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "xfce" ]; then
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
	apt install -y linux-headers-amd64 nvidia-driver firmware-misc-nonfree libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 firmware-linux-nonfree

	# Adding vivaldi repo
	wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | apt-key add -
	add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'
	apt update
	apt install -y vivaldi-stable
	# apt remove -y firefox-esr

	# Installing strawberry
	curl -s https://api.github.com/repos/strawberrymusicplayer/strawberry/releases/latest |
		grep "browser_download_url" |
		grep "strawberry_" |
		grep "bullseye" |
		cut -d '"' -f 4 |
		wget -O strawberry.deb -qi -
	apt install -y ./strawberry.deb

	# Installing wine
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	apt-key add winehq.key
	echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" | tee /etc/apt/sources.list.d/wine.list
	apt update
	apt install -y winehq-staging winetricks

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

	# Installing required applications
	apt install -y build-essential steam vim nano fonts-noto fonts-noto-cjk fonts-noto-mono mednafen mednaffe telegram-desktop neovim python3-neovim gimp flatpak papirus-icon-theme zsh zsh-autosuggestions zsh-syntax-highlighting thermald mpv youtube-dl chromium libreoffice firmware-linux libfido2-1 gamemode hyphen-en-us mythes-en-us btrfs-progs gparted ntfs-3g exfat-utils f2fs-tools unrar hplip printer-driver-cups-pdf earlyoom obs-studio gstreamer1.0-vaapi desmume openjdk-11-jdk pamu2fcfg libpam-u2f zip unzip nodejs npm php snapd filezilla virtualbox virtualbox-ext-pack

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
		apt install -y qbittorrent palapeli kmahjongg kpat thunderbird thunderbird-l10n-es-es yakuake gnome-keyring libpam-gnome-keyring libpam-kwallet5 sddm-theme-breeze kdeconnect plasma-browser-integration qemu-system libvirt-clients libvirt-daemon-system virt-manager xdg-desktop-portal-kde ffmpegthumbs kde-config-tablet dolphin-plugins k3b kio-audiocd libreoffice-qt5 libreoffice-kf5 xdg-desktop-portal

		# Adding user to libvirt group
		adduser $user libvirt

		# Remove unwanted applications
		apt remove -y konversation akregator kmail konqueror dragonplayer juk kaddressbook korganizer xdg-desktop-portal-gtk

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
	flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app org.jdownloader.JDownloader org.DolphinEmu.dolphin-emu com.google.AndroidStudio org.eclipse.Java io.dbeaver.DBeaverCommunity com.axosoft.GitKraken com.jetbrains.IntelliJ-IDEA-Community rest.insomnia.Insomnia

	# Updating grub
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
	sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
	update-grub

	# Setting hexagon_2 plymouth theme
	curl -LO "https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz"
	tar xzvf hexagon_2.tar.gz
	cp -r hexagon_2 /usr/share/plymouth/themes
	plymouth-set-default-theme -R hexagon_2

	# Copying prime-run script
	cp $directory/../dotfiles/prime-run /usr/bin/prime-run
	chmod +x /usr/bin/prime-run

	# Putting sysctl options
	echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

	# Installing xampp
	curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" >xampp.run
	chmod 755 xampp.run
	./xampp.run --unattendedmodeui minimal --mode unattended
	rm xampp.run

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
	echo "xfce - to configure the XFCE desktop"
fi

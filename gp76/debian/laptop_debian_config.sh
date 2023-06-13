#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "xfce" ] || [ "$1" == "cinnamon" ]; then
	user=$SUDO_USER

	# Installing curl
	apt install -y curl wget software-properties-common pkg-config

	# Adding backports and fasttrack repos
	echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free" | tee -a /etc/apt/sources.list
	apt update
	apt install -y fasttrack-archive-keyring
	echo "deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib" | tee -a /etc/apt/sources.list
	echo "deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-backports-staging main contrib" | tee -a /etc/apt/sources.list
	apt update

	# Installing wine
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	cp winehq.key /etc/apt/trusted.gpg.d/winehq.asc
	echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" | tee /etc/apt/sources.list.d/wine.list
	apt update
	apt install -y winehq-staging
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
	echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" | tee /etc/apt/sources.list.d/lutris.list
	wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_11/Release.key -O- | tee /etc/apt/trusted.gpg.d/lutris.asc
	apt update
	apt install -y lutris

	# Installing nodejs
	curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
	apt-get install -y nodejs

	# Installing required applications
	apt install -y build-essential vim nano fonts-noto fonts-noto-cjk fonts-noto-mono mednafen mednaffe neovim python3-neovim gimp flatpak papirus-icon-theme zsh zsh-autosuggestions zsh-syntax-highlighting thermald mpv chromium libreoffice firmware-linux libfido2-1 gamemode hyphen-en-us mythes-en-us btrfs-progs gparted ntfs-3g f2fs-tools unrar hplip printer-driver-cups-pdf earlyoom gstreamer1.0-vaapi desmume openjdk-17-jdk zip unzip wget yt-dlp pcsx2 cryptsetup nextcloud-desktop p7zip neofetch zstd zram-tools mpv-mpris strawberry

	# Enabling services
	systemctl enable thermald

	# Installing computer specific applications
	apt install -y pamu2fcfg libpam-u2f

	if [ "$1" == "gnome" ]; then
		# Installing required packages
		apt install ffmpegthumbnailer tilix transmission-gtk evolution aisleriot gnome-mahjongg 

		# Remove unwanted applications
		apt remove -y four-in-a-row five-or-more gnome-2048 gnome-chess gnome-klotski hitori gnome-tetravex gnome-taquin gnome-robots gnome-music zutty totem rhythmbox lightsoff tali swell-foop gnome-sudoku gnome-taquin tali gnome-mines quadrapassel gnome-nibbles iagno gnome-shell-extensions gnome-initial-setup im-config synaptic yelp debian-reference-common

		# Disabling wayland
		sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm/custom.conf

		# Setting firefox env var
		echo "MOZ_ENABLE_WAYLAND=1" | tee -a /etc/environment

		# Adding ssh-askpass env var
		echo "SSH_ASKPASS=/usr/libexec/seahorse/ssh-askpass" | tee -a /etc/environment	

	elif [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		# Installing required packages
		apt install -y qbittorrent palapeli kmahjongg kpat thunderbird thunderbird-l10n-es-es gnome-keyring libpam-gnome-keyring libpam-kwallet5 sddm-theme-breeze kdeconnect plasma-browser-integration xdg-desktop-portal-kde ffmpegthumbs kde-config-tablet dolphin-plugins k3b kio-audiocd libreoffice-qt5 libreoffice-kf5 xdg-desktop-portal qemu-system libvirt-daemon-system virt-manager 

		# Adding user to libvirt group
		user="$SUDO_USER"
		usermod -aG libvirt $user

		# Remove unwanted applications
		apt remove -y konversation akregator kmail konqueror dragonplayer juk kaddressbook korganizer vlc termit

		# Adding environment variable
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

		# Adding gnome-keyring settings
		cp /etc/pam.d/login /etc/pam.d/login.bak
		awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/login /etc/pam.d/login >login
		if diff /etc/pam.d/login.bak login; then
			awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/login /etc/pam.d/login >login
			cp login /etc/pam.d/login
		else
			cp login /etc/pam.d/login
		fi
		rm login
		cp /etc/pam.d/login /etc/pam.d/login.bak
		awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/login /etc/pam.d/login >login
		if diff /etc/pam.d/login.bak login; then
			awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/login /etc/pam.d/login >login
			cp login /etc/pam.d/login
		else
			cp login /etc/pam.d/login
		fi
		rm login
		echo "password	optional	pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

	elif [ "$1" == "xfce" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends thunderbird ffmpegthumbnailer tumbler tumbler-plugins-extra transmission-gtk 

	elif [ "$1" == "cinnamon" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends materia-gtk-theme materia-kde qt5-style-kvantum transmission-gtk aisleriot gnome-mahjongg ffmpegthumbnailer lightdm-settings slick-greeter xdg-desktop-portal-gtk libpam-gnome-keyring libgepub-0.6-0 libgsf-1-114 libwebp6 libopenraw7 geary 

		# Removing unwanted applications
		apt remove -y gnome-2048 gnome-taquin tali gnome-robots gnome-tetravex quadrapassel four-in-a-row five-or-more lightsoff gnome-chess hoichess gnome-klotski swell-foop gnome-mines gnome-nibbles iagno gnome-sudoku inkscape hexchat remmina pidgin rhythmbox sound-juicer totem vlc hitori termit shotwell synaptic thunderbird

		# Adding environment variable
		echo "QT_STYLE_OVERRIDE=kvantum" | tee -a /etc/environment
	fi

	# Updating grub
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
	sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
	update-grub

	#Add flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	#Install flatpak applications
	flatpak install -y flathub org.jdownloader.JDownloader org.telegram.desktop org.nicotine_plus.Nicotine com.obsproject.Studio org.DolphinEmu.dolphin-emu sh.ppy.osu com.heroicgameslauncher.hgl com.valvesoftware.Steam

	# Installing kde themes
	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then 
		flatpak install -y flathub org.gtk.Gtk3theme.Breeze org.gtk.Gtk3theme.Breeze-Dark
	else
		flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark
	fi

	# Configure zram swap
	cat > /etc/default/zramswap <<EOF
ALGO=zstd
PRIORITY=100
PERCENT=50
EOF

	# Decrease swappiness
 	echo "vm.swappiness=1" | tee -a /etc/sysctl.d/99-sysctl.conf
 	echo "vm.vfs_cache_pressure=50" | tee -a /etc/sysctl.d/99-sysctl.conf

 	# Virtual memory tuning
 	echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
 	echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

 	# Optimize SSD and HDD performance
 	cat > /etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

 	# Removing uneeded packages
 	apt autoremove --purge -y

	# Clear cache
	apt clean

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
	echo "xfce - to configure the XFCE desktop"
fi

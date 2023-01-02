#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ]; then

	user=$SUDO_USER

	#DNF Tweaks
	echo "deltarpm=true" | tee -a /etc/dnf/dnf.conf
	echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf

	#Setting up hostname
	hostnamectl set-hostname link-pc

	#Enabling mednaffe repo
	dnf copr enable alderaeney/mednaffe -y

	#Enabling vivaldi repo
	# dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo

	#Adding brave repo
	# dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
	# rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

	# Adding openrazer repos
	dnf config-manager --add-repo https://download.opensuse.org/repositories/hardware:razer/Fedora_37/hardware:razer.repo

	# Input remapper copr repo
	dnf copr enable sunwire/input-remapper -y

	# Heroic games launcher repo
	dnf copr enable atim/heroic-games-launcher -y

	# Adding docker repo
	# dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

	# Enabling third party repositories
	dnf install -y fedora-workstation-repositories
	dnf config-manager --set-enabled google-chrome

	#Install VSCode
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

	# Installing xanmod kernel
	# dnf copr enable rmnscnce/kernel-xanmod -y
	# dnf in -y kernel-xanmod-edge kernel-xanmod-edge-devel kernel-xanmod-edge-headers

	# Upgrade system
	dnf upgrade -y --refresh

	# Development tools
	dnf groupinstall "C Development Tools and Libraries" -y
	dnf groupinstall "Development Tools" -y

	#Install required packages
	dnf install -y vim lutris steam flatpak zsh zsh-syntax-highlighting papirus-icon-theme wine winetricks dolphin-emu zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code thermald python-neovim libfido2 strawberry mednafen mednaffe webp-pixbuf-loader desmume unrar gimp protontricks java-11-openjdk-devel ffmpeg pcsx2 neofetch unzip zip cryptsetup alsa-plugins-pulseaudio.x86_64 alsa-lib-devel.x86_64 nicotine+ yt-dlp p7zip razergenie openrazer-meta nextcloud-client chromium-freeworld sqlite hunspell-ca hunspell-es-ES mythes-ca mythes-es mythes-en hyphen-es hyphen-ca hyphen-en aspell-ca aspell-es aspell-en android-tools piper redhat-lsb-core solaar zpaq python3-input-remapper heroic-games-launcher-bin lm_sensors mpv mpv-mpris zstd openssl

	# Installing computer specific packages
	dnf in -y mesa-freeworld

	# Installing docker
	# dnf in -y docker-ce docker-ce-cli containerd.io docker-compose
	# systemctl enable --now docker

	# Enabling services
	user="$SUDO_USER"
	systemctl enable thermald input-remapper 

	# Adding user to plugdev group
	user="$SUDO_USER"
	usermod -aG plugdev $user

	# Adding user to docker group
	# user="$SUDO_USER"
	# usermod -aG docker $user

	# Installing mongodb compass
	# dnf in -y "https://github.com/mongodb-js/compass/releases/download/v1.32.6/mongodb-compass-1.32.6.x86_64.rpm"

	#Update Appstream data
	dnf groupupdate core -y

	#Install multimedia codecs
	dnf groupupdate sound-and-video -y
	dnf install -y libdvdcss
	dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
	dnf install -y lame\* --exclude=lame-devel
	dnf group upgrade -y --with-optional Multimedia

	# Desktop specific configs
	if [ "$1" == "gnome" ]; then
		# Uninstalling GNOME applications
		dnf rm -y totem rhythmbox

		# Installing GNOME applications
		dnf in -y gnome-tweaks ffmpegthumbnailer aisleriot gnome-mahjongg geary brasero file-roller deluge deluge-gtk seahorse

		#Disable wayland
		sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf

		# Adding ssh-askpass env var
		echo "SSH_ASKPASS=/usr/libexec/seahorse/ssh-askpass" | tee -a /etc/environment

	elif [ "$1" == "kde" ]; then
		# Uninstalling KDE applications
		dnf rm -y kolourpaint akregator kmail konversation krfb kmines dragon elisa-player kaddressbook

		# Installing KDE applications
		dnf in -y palapeli ksshaskpass kde-connect simple-scan kio_mtp kio-extras kio-gdrive kate qbittorrent filelight kcm_wacomtablet fuse-sshfs spectacle kcalc kdegraphics-thumbnailers kcron ksystemlog kgpg kcharselect kdenetwork-filesharing audiocd-kio kfind kde-print-manager signon-kwallet-extension gnome-boxes xdg-desktop-portal-kde xdg-desktop-portal ffmpegthumbs 

		# Adding GTK_USE_PORTAL=1 to /etc/environment
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

		# Copying ksshaskpass
		echo "SSH_ASKPASS=/usr/bin/ksshaskpass" | tee -a /etc/environment
	fi

	#Add flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	#Install flatpak applications
	flatpak install -y flathub org.jdownloader.JDownloader org.gtk.Gtk3theme.Adwaita-dark sh.ppy.osu org.telegram.desktop com.obsproject.Studio

	# Installing yt-dlp
	ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl

	# Decrease swappiness
	echo "vm.swappiness=1" | tee -a /etc/sysctl.d/99-sysctl.conf
	echo "vm.vfs_cache_pressure=50" | tee -a /etc/sysctl.d/99-sysctl.conf

	# Virtual memory tuning
	echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
	echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

	# Kernel hardening
	echo "kernel.kptr_restrict = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
	echo "net.core.bpf_jit_harden=2" | tee -a /etc/sysctl.d/99-sysctl.conf
	echo "kernel.kexec_load_disabled = 1" | tee -a /etc/sysctl.d/99-sysctl.conf

	# Optimize SSD and HDD performance
	cat > /etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

	# Fixing font rendering
	# cp $directory/local.conf /etc/fonts/local.conf

else
	echo "gnome -- GNOME config"
	echo "kde -- KDE config"
fi

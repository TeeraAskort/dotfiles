#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then

	# Installing repos
	zypper ar http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/games.repo
	zypper ar http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/Emulators:Wine.repo
	zypper ar http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/shells:zsh-users:zsh-syntax-highlighting.repo
	zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
	zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/openSUSE_Tumbleweed/shells:zsh-users:zsh-completions.repo
	zypper ar https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/Emulators.repo
	zypper addrepo https://download.opensuse.org/repositories/hardware/openSUSE_Tumbleweed/hardware.repo
	zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
	zypper addrepo https://download.opensuse.org/repositories/games:tools/openSUSE_Tumbleweed/games:tools.repo
	zypper addrepo https://download.opensuse.org/repositories/mozilla/openSUSE_Tumbleweed/mozilla.repo
	zypper addrepo https://download.opensuse.org/repositories/home:Alderaeney/openSUSE_Tumbleweed/home:Alderaeney.repo
	# zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo

	# Adding VSCode repo
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'

	# Adding brave repo
	# rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
	# zypper addrepo https://brave-browser-rpm-release.s3.brave.com/x86_64/ brave-browser

	# Refreshing the repos
	zypper --gpg-auto-import-keys refresh

	# Updating system
	zypper dup -y

	# Updating the system
	zypper dist-upgrade --from packman --allow-vendor-change -y

	# Installing wine-staging from wine repo
	zypper in -y --from "Wine (openSUSE_Tumbleweed)" wine-staging wine-staging-32bit dxvk dxvk-32bit

	# Installing codecs
	zypper install -y --from packman --allow-vendor-change ffmpeg gstreamer-plugins-{good,bad,ugly,libav} libavcodec-full

	# Installing discord from games:tools repo
	zypper in -y --from 'Tools for Gamers (openSUSE_Tumbleweed)' --allow-vendor-change discord gamemoded protontricks 

	# Installing strawberry compiled against QT5 from my repo
	zypper in --from "home:Alderaeney (openSUSE_Tumbleweed)" -y strawberry.x86_64

	# Installing basic packages
	zypper in -y chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions mpv mpv-mpris strawberry flatpak thermald nodejs npm python39-neovim neovim noto-sans-cjk-fonts noto-coloremoji-fonts code earlyoom desmume zip gimp flatpak-zsh-completion zsh-completions neofetch virtualbox filezilla php-composer2 virtualbox-host-source kernel-devel kernel-default-devel cryptsetup yt-dlp pcsx2 libasound2.x86_64 docker python3-docker-compose minigalaxy systemd-zram-service nextcloud-desktop alsa-plugins-pulse.x86_64 minecraft-launcher

	# Enabling thermald service
	systemctl enable thermald earlyoom docker

	# Starting services
	systemctl start docker

	# Starting zram service
	zramswapon

	# Adding current user to docker group
	user="$SUDO_USER"
	usermod -G docker -a $user

	# Installing computer specific applications
	zypper in -y kernel-firmware-amdgpu libdrm_amdgpu1 libdrm_amdgpu1-32bit libdrm_radeon1 libdrm_radeon1-32bit libvulkan_radeon libvulkan_radeon-32bit libvulkan1 libvulkan1-32bit

	# Removing unwanted applications
	zypper rm -y --clean-deps git-gui vlc vlc-qt vlc-noX 

	# Block vlc from installing
	zypper addlock vlc-beta
	zypper addlock vlc

	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		# Installing DE specific applications
		zypper in -y yakuake qbittorrent kdeconnect-kde palapeli gnome-keyring pam_kwallet gnome-keyring-pam k3b kio_audiocd MozillaThunderbird

		# Removing unwanted DE specific applications
		zypper rm -y --clean-deps konversation kmines ksudoku kreversi

		# Adding GTK_USE_PORTAL
		echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

		# Adding gnome-keyring settings
		awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm
		awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm

	elif [ "$1" == "gnome" ]; then 
		# Removing unwanted DE specific applications
		zypper rm -y --clean-deps gnome-music totem lightsoff quadrapassel gnome-chess gnome-mines polari pidgin iagno swell-foop gnome-sudoku

		# Installing DE specific applications
		zypper in -y adwaita-qt5 QGnomePlatform aisleriot gnome-session-wayland

 		# Adding gnome theming to qt
		echo "QT_QPA_PLATFORMTHEME=gnome" | tee -a /etc/environment
	fi

	# Installing firefox from mozilla repo
	zypper dup --from "Mozilla based projects (openSUSE_Tumbleweed)" --allow-vendor-change -y

	# Adding kde connect firewall rule
	firewall-cmd --zone=public --permanent --add-service=kdeconnect
	firewall-cmd --reload

	# Add user to wheel group
	user=$SUDO_USER
	usermod -aG wheel $user

	# Add sudo rule to use wheel group
	if [[ ! -e /etc/sudoers.d ]]; then
		mkdir -p /etc/sudoers.d
	fi
	echo "%wheel ALL=(ALL) ALL" | tee -a /etc/sudoers.d/usewheel

	# Use user password for sudo instead of target user password
	sed -i "s/Defaults targetpw/# Defaults targetpw/g" /etc/sudoers
	sed -i "s/ALL   ALL=(ALL) ALL/# ALL ALL=(ALL) ALL/g" /etc/sudoers

	# Using sudo instead of su for graphical sudo
	echo "Defaults env_keep += \"DISPLAY XAUTHORITY\"" | tee -a /etc/sudoers.d/env_vars

	# Adding flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	# Installing flatpak apps
	flatpak install -y flathub org.jdownloader.JDownloader com.github.AmatCoder.mednaffe org.telegram.desktop com.axosoft.GitKraken com.getpostman.Postman io.dbeaver.DBeaverCommunity com.jetbrains.PhpStorm com.obsproject.Studio org.nicotine_plus.Nicotine org.DolphinEmu.dolphin-emu

	# Installing flatpak themes
	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		flatpak install -y flathub org.gtk.Gtk3theme.Breeze-Dark org.gtk.Gtk3theme.Breeze
	 	user="$SUDO_USER"
		sudo -u $user flatpak override --user --filesystem=/home/$user/.local/share/color-schemes
	fi

	if [ "$1" == "gnome" ]; then 
 		flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark
	fi

	# Flatpak overrides
	user="$SUDO_USER"
 	sudo -u $user flatpak override --user --filesystem=/home/$user/.fonts

	# Adding user to vboxusers group
	user="$SUDO_USER"
	usermod -aG vboxusers $user 

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
fi

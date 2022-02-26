#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "cinnamon" ]; then

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
	if [ "$1" == "xfce" ]; then
		zypper addrepo https://download.opensuse.org/repositories/X11:xfce/openSUSE_Tumbleweed/X11:xfce.repo
	fi
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
	# zypper dist-upgrade --from packman --allow-vendor-change -y

	# Installing wine-staging from wine repo
	zypper in -y --from "Wine (openSUSE_Tumbleweed)" wine-staging wine-staging-32bit dxvk dxvk-32bit

	# Installing codecs
	zypper install -y --from packman --allow-vendor-change ffmpeg gstreamer-plugins-{good,bad,ugly,libav} libavcodec-full

	# Installing discord from games:tools repo
	zypper in -y --from 'Tools for Gamers (openSUSE_Tumbleweed)' --allow-vendor-change discord gamemoded protontricks 

	# Installing strawberry compiled against QT5 from my repo
	zypper in --from "home:Alderaeney (openSUSE_Tumbleweed)" -y strawberry.x86_64

	# Installing basic packages
	zypper in -y chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions flatpak thermald nodejs npm python39-neovim neovim noto-sans-cjk-fonts noto-coloremoji-fonts code earlyoom desmume zip gimp flatpak-zsh-completion zsh-completions neofetch cryptsetup yt-dlp pcsx2 libasound2.x86_64 minigalaxy systemd-zram-service syncthing alsa-plugins-pulse.x86_64 minecraft-launcher 7zip

	# Enabling thermald service
	user="$SUDO_USER"
	systemctl enable thermald earlyoom syncthing@${user}.service

	# Starting zram service
	zramswapon

	# Installing computer specific applications
	zypper in -y kernel-firmware-amdgpu libdrm_amdgpu1 libdrm_amdgpu1-32bit libdrm_radeon1 libdrm_radeon1-32bit libvulkan_radeon libvulkan_radeon-32bit libvulkan1 libvulkan1-32bit

	# Removing unwanted applications
	zypper rm -y  git-gui vlc vlc-qt vlc-noX 

	# Block vlc from installing
	zypper addlock vlc-beta
	zypper addlock vlc
	zypper youtube-dl

	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		# Installing DE specific applications
		zypper in -y yakuake qbittorrent kdeconnect-kde palapeli gnome-keyring pam_kwallet gnome-keyring-pam k3b kio_audiocd MozillaThunderbird mpv mpv-mpris

		# Removing unwanted DE specific applications
		zypper rm -y  konversation kmines ksudoku kreversi

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
		zypper rm -y gnome-music totem lightsoff quadrapassel gnome-chess gnome-mines polari pidgin iagno swell-foop gnome-sudoku

		# Installing DE specific applications
		zypper in -y adwaita-qt5 QGnomePlatform aisleriot ffmpegthumbnailer webp-pixbuf-loader celluloid

 		# Adding gnome theming to qt
		echo "QT_QPA_PLATFORMTHEME=gnome" | tee -a /etc/environment

	elif [ "$1" == "cinnamon" ]; then
		# Removing unwanted DE specific applications
		zypper rm -y hexchat celluloid rhythmbox xed

		# Installing DE specific applications
		zypper in -y adwaita-qt5 QGnomePlatform aisleriot ffmpegthumbnailer webp-pixbuf-loader tilix gnome-mahjongg transmission-gtk gedit file-roller gvfs gvfs-backends gvfs-backend-samba libgepub-0_6-0 libgsf-1-114 libopenraw1 gnome-sound-recorder nemo-extension-nextcloud nemo-extension-fileroller nemo-extension-preview nemo-extension-share nemo-extension-image-converter books gnome-disk-utility lightdm-slick-greeter brasero geary

		# Adding gnome theming to qt
		echo "QT_STYLE_OVERRIDE=adwaita-dark" | tee -a /etc/environment

	elif [ "$1" == "xfce" ]; then
		# Removing unwanted DE specific applications
		zypper rm -y blueman parole pidgin remmina pragha

		# Installing DE specific applications
		zypper in -y xcape playerctl transmission-gtk gvfs gvfs-backends gvfs-backend-samba gvfs-fuse ffmpegthumbnailer webp-pixbuf-loader tilix gnome-mahjongg adwaita-qt5 QGnomePlatform aisleriot libgepub-0_6-0 libgsf-1-114 libopenraw1 brasero pavucontrol xarchiver blueberry evince gnome-keyring-pam gnome-keyring mpv mpv-mpris

		# Adding gnome theming to qt
		echo "QT_STYLE_OVERRIDE=adwaita-dark" | tee -a /etc/environment

		# Adding xprofile to user link
		user="$SUDO_USER"
		sudo -u $user echo "xcape -e 'Super_L=Control_L|Escape'" | tee -a /home/$user/.xprofile

		# Setting cursor size in Xresources
		sudo -u $user echo "Xcursor.size: 16" | tee -a /home/$user/.Xresources

	fi

	# Installing firefox from mozilla repo
	zypper dup --from "Mozilla based projects (openSUSE_Tumbleweed)" --allow-vendor-change -y

	# Add user to wheel group
	user=$SUDO_USER
	usermod -aG wheel $user

	# Add sudo rule to use wheel group
	if [[ ! -e /etc/sudoers.d ]]; then
		mkdir -p /etc/sudoers.d
	fi
	echo "%wheel ALL=(ALL) ALL" | tee -a /etc/sudoers.d/usewheel

	# Use user password for sudo instead of target user password
	sed -i "s/Defaults targetpw/#Defaults targetpw/g" /etc/sudoers
	sed -i "s/ALL   ALL=(ALL) ALL/# ALL ALL=(ALL) ALL/g" /etc/sudoers

	# Using sudo instead of su for graphical sudo
	echo "Defaults env_keep += \"DISPLAY XAUTHORITY\"" | tee -a /etc/sudoers.d/env_vars

	# Configuring policykit
	sed -i "s/user:0/group:wheel/g" /usr/share/polkit-1/rules.d/50-default.rules

	# Copy plokit config
	cp $directory/org.opensuse.pkexec.yast2.policy /usr/share/polkit-1/actions/org.opensuse.pkexec.yast2.policy

	# Changing all yast executables to pkexec
	bash $directory/fix-yast.sh

	# Adding flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	# Installing flatpak apps
	flatpak install -y flathub org.jdownloader.JDownloader com.github.AmatCoder.mednaffe org.telegram.desktop com.obsproject.Studio org.nicotine_plus.Nicotine org.DolphinEmu.dolphin-emu

	# Installing flatpak themes
	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		flatpak install -y flathub org.gtk.Gtk3theme.Breeze-Dark org.gtk.Gtk3theme.Breeze
	 	user="$SUDO_USER"
		sudo -u $user flatpak override --user --filesystem=/home/$user/.local/share/color-schemes
	fi

	if [ "$1" == "gnome" ] || [ "$1" == "xfce" ]; then
 		flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark
	fi

	if [ "$1" == "cinnamon" ]; then
		flatpak install -y flathub org.gtk.Gtk3theme.Mint-Y-Dark
	fi

	# Flatpak overrides
	user="$SUDO_USER"
 	sudo -u $user flatpak override --user --filesystem=/home/$user/.fonts

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

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
	echo "cinnamon - to configure the Cinnamon desktop"
fi

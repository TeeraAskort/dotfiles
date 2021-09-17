#!/usr/bin/env bash

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then

	rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep WDC_WDS120G2G0B-00EPW0 | cut -d" " -f1)

	# Installing repos
	zypper ar http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/games.repo
	zypper ar http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/Emulators:Wine.repo
	zypper ar http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/shells:zsh-users:zsh-syntax-highlighting.repo
	zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
	zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/openSUSE_Tumbleweed/shells:zsh-users:zsh-completions.repo
	zypper ar https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/Emulators.repo
	zypper addrepo https://download.opensuse.org/repositories/hardware/openSUSE_Tumbleweed/hardware.repo
	zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
	zypper addrepo https://download.opensuse.org/repositories/home:buschmann23/openSUSE_Tumbleweed/home:buschmann23.repo
	# zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo
	zypper addrepo https://download.opensuse.org/repositories/system:snappy/openSUSE_Tumbleweed/system:snappy.repo

	# Adding VSCode repo
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'

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

	# Installing basic packages
	zypper in -y chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions mpv mpv-mpris strawberry flatpak gamemoded thermald plymouth-plugin-script nodejs npm python39-neovim neovim noto-sans-cjk-fonts noto-coloremoji-fonts earlyoom discord code patterns-openSUSE-kvm_server patterns-server-kvm_tools qemu-audio-pa desmume zip dolphin-emu gimp flatpak-zsh-completion zsh-completions protontricks neofetch php8 snapd virtualbox filezilla

	# Enabling thermald service
	systemctl enable thermald earlyoom libvirtd

	# Removing unwanted applications
	zypper rm -y git-gui vlc vlc-qt vlc-noX

	# Block vlc from installing
	zypper addlock vlc-beta
	zypper addlock vlc

	if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		# Installing DE specific applications
		zypper in -y yakuake qbittorrent kdeconnect-kde palapeli gnome-keyring pam_kwallet gnome-keyring-pam k3b kio_audiocd MozillaThunderbird

		# Removing unwanted DE specific applications
		zypper rm -y konversation kmines ksudoku kreversi

		# Adding GTK_USE_PORTAL
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
	fi

	# Changing plymouth theme
	until wget https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz; do
		echo "Download failed, retrying"
	done
	tar xzvf hexagon_2.tar.gz
	mv hexagon_2 /usr/share/plymouth/themes/
	plymouth-set-default-theme -R hexagon_2
	rm hexagon_2.tar.gz

	# Removing double encryption password asking
	touch /.root.key
	chmod 600 /.root.key
	dd if=/dev/urandom of=/.root.key bs=1024 count=1
	clear
	echo "Enter disk encryption password"
	until cryptsetup luksAddKey /dev/${rootDisk}2 /.root.key; do
		echo "Retrying"
	done
	sed -i "/WDC_WDS120G2G0B-00EPW0/ s/none/\/.root.key/g" /etc/crypttab
	echo -e 'install_items+=" /.root.key "' | tee --append /etc/dracut.conf.d/99-root-key.conf >/dev/null
	echo "/boot/ root:root 700" | tee -a /etc/permissions.local
	chkstat --system --set
	mkinitrd

	# Adding flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	# Installing flatpak apps
	flatpak install -y flathub io.lbry.lbry-app org.jdownloader.JDownloader com.google.AndroidStudio com.jetbrains.IntelliJ-IDEA-Community org.eclipse.Java com.mojang.Minecraft com.github.AmatCoder.mednaffe org.telegram.desktop io.dbeaver.DBeaverCommunity com.axosoft.GitKraken rest.insomnia.Insomnia

	# Flatpak overrides
	flatpak override --filesystem=~/.fonts

	# Installing xampp
	curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" >xampp.run
	chmod 755 xampp.run
	./xampp.run --unattendedmodeui minimal --mode unattended
	rm xampp.run

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
fi

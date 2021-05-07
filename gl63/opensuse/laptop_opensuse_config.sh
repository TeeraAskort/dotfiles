#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Installing repos
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
sudo zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
sudo zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators
sudo zypper addrepo https://download.opensuse.org/repositories/hardware/openSUSE_Tumbleweed/hardware.repo
sudo zypper ar https://packagecloud.io/slacktechnologies/slack/fedora/21/x86_64 slack

# Adding VSCode repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'

# Adding chrome repo
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
wget https://dl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub

# Refreshing the repos
sudo zypper refresh

# Updating the system
sudo zypper dup -y

# Installing basic packages
sudo zypper in -y google-chrome-stable steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions mpv mpv-mpris strawberry dolphin-emu telegram-desktop flatpak gamemoded thermald plymouth-plugin-script nodejs15 npm15 intel-undervolt python39-neovim noto-sans-cjk-fonts noto-coloremoji-fonts code earlyoom pam_u2f NetworkManager-l2tp xf86-video-intel patterns-openSUSE-kvm_server patterns-server-kvm_tools qemu-audio-pa slack discord

# Enabling thermald service
sudo systemctl enable thermald intel-undervolt earlyoom

# Removing unwanted applications
sudo zypper rm -y git-gui

# Installing NVIDIA drivers
sudo OneClickInstallCLI https://www.opensuse-community.org/nvidia_G05.ymp

if [ $XDG_CURRENT_DESKTOP = "KDE" ]; then
	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-kde.ymp

	# Installing DE specific applications
	sudo zypper in -y yakuake qbittorrent kdeconnect-kde palapeli gnome-keyring

	# Removing unwanted DE specific applications
	sudo zypper rm -y konversation kmines ksudoku kreversi

	## Setting up gnome-keyring on sddm
	if [ -e /etc/pam.d/sddm ]; then
		sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
		awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth      optional    pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth      optional    pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			sudo cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm
	fi

	if [ -e /etc/pam.d/sddm ]; then
		sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
		awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session   optional    pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session   optional    pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			sudo cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm
	fi

	if [ -e /etc/pam.d/sddm ]; then
		sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
		awk "FNR==NR{ if (/password /) p=NR; next} 1; FNR==p{ print \"password       optional        pam_gnome_keyring.so use_authtok\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
		if diff /etc/pam.d/sddm.bak sddm; then
			awk "FNR==NR{ if (/password\t/) p=NR; next} 1; FNR==p{ print \"password       optional        pam_gnome_keyring.so use_authtok\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
			sudo cp sddm /etc/pam.d/sddm
		else
			sudo cp sddm /etc/pam.d/sddm
		fi
		rm sddm
	fi
fi

# Changing plymouth theme
wget https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz
tar xzvf hexagon_2.tar.gz
sudo mv hexagon_2 /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R hexagon_2
rm hexagon_2.tar.gz

# Removing double encryption password asking
sudo touch /.root.key
sudo chmod 600 /.root.key
sudo dd if=/dev/urandom of=/.root.key bs=1024 count=1
clear
echo "Enter disk encryption password"
until sudo cryptsetup luksAddKey /dev/nvme0n1p2 /.root.key
do
	echo "Retrying"
done
sudo sed -i "/WDC_WDS500G2B0C/ s/none/\/.root.key/g" /etc/crypttab
echo -e 'install_items+=" /.root.key "' | sudo tee --append /etc/dracut.conf.d/99-root-key.conf >/dev/null
echo "/boot/ root:root 700" | sudo tee -a /etc/permissions.local
sudo chkstat --system --set
sudo mkinitrd

#Intel undervolt configuration
sudo sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

# Adding flathub repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
sudo flatpak install -y flathub io.lbry.lbry-app com.google.AndroidStudio org.jdownloader.JDownloader org.gimp.GIMP com.getpostman.Postman io.dbeaver.DBeaverCommunity com.anydesk.Anydesk org.jdownloader.JDownloader

# Flatpak overrides
sudo flatpak override --filesystem=~/.fonts

# Add sysctl config
echo "dev.i915.perf_stream_paranoid=0" | sudo tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
sudo npm i -g @angular/cli
sudo ng analytics off

# Installing ionic
sudo npm i -g @ionic/cli

# Copying prime-run
sudo cp $directory/../dotfiles/prime-run /usr/bin
sudo chmod +x /usr/bin/prime-run

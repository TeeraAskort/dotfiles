#!/usr/bin/env bash

rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep WDC_WDS120G2G0B-00EPW0 | cut -d" " -f1)

# Installing repos
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
sudo zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
sudo zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators
sudo zypper addrepo https://download.opensuse.org/repositories/hardware/openSUSE_Tumbleweed/hardware.repo

# Adding chrome repo
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
wget https://dl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub

# Refreshing the repos
sudo zypper refresh

# Updating the system
sudo zypper dup -y 

# Installing basic packages
sudo zypper in -y google-chrome-stable steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions mpv mpv-mpris strawberry dolphin-emu telegram-desktop flatpak gamemoded thermald plymouth-plugin-script nodejs npm python39-neovim noto-sans-cjk-fonts noto-coloremoji-fonts earlyoom discord

# Enabling thermald service
sudo systemctl enable thermald earlyoom

# Removing unwanted applications
sudo zypper rm -y git-gui

if [ $XDG_CURRENT_DESKTOP = "KDE" ]; then
	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-kde.ymp

	# Installing DE specific applications
	sudo zypper in -y yakuake qbittorrent kdeconnect-kde palapeli 

	# Removing unwanted DE specific applications
	sudo zypper rm -y konversation kmines ksudoku kreversi 
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
until sudo cryptsetup luksAddKey /dev/${rootDisk}2 /.root.key
do
	echo "Retrying"
done
sudo sed -i "/WDC_WDS120G2G0B-00EPW0/ s/none/\/.root.key/g" /etc/crypttab
echo -e 'install_items+=" /.root.key "' | sudo tee --append /etc/dracut.conf.d/99-root-key.conf >/dev/null
echo "/boot/ root:root 700" | sudo tee -a /etc/permissions.local
sudo chkstat --system --set
sudo mkinitrd

# Adding flathub repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
sudo flatpak install -y flathub io.lbry.lbry-app org.jdownloader.JDownloader org.gimp.GIMP org.jdownloader.JDownloader

# Flatpak overrides
sudo flatpak override --filesystem=~/.fonts

# Add sysctl config
echo "dev.i915.perf_stream_paranoid=0" | sudo tee -a /etc/sysctl.d/99-sysctl.conf

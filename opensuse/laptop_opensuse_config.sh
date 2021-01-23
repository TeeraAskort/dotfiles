#!/bin/bash

# Installing repos
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
sudo zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
sudo zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators

# Refreshing the repos
sudo zypper refresh

# Updating the system
sudo zypper dup

# Installing nvidia drivers
sudo OneClickInstallCLI https://www.opensuse-community.org/nvidia_G05.ymp

# Installing codecs
if [ $XDG_CURRENT_DESKTOP = "KDE" ]; then

	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-kde.ymp

	# Installing packages
	sudo zypper in chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions yakuake mpv mpv-mpris strawberry dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel qbittorrent emacs kdeconnect-kde plymouth-plugin-script

	# Remove unwanted packages
	sudo zypper rm git-gui akregator konversation kmines ksudoku kreversi 

else

	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-gnome.ymp

	# Installing packages
	sudo zypper in chromium steam lutris plata-theme papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions tilix mpv rhythmbox dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel emacs plymouth-plugin-script

fi

# Enabling thermald service
sudo systemctl enable thermald

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
sudo cryptsetup luksAddKey /dev/nvme0n1p2 /.root.key
sudo sed -i "/^cr_nvme/ s/none/\/.root.key/g" /etc/crypttab
echo -e 'install_items+=" /.root.key "' | sudo tee --append /etc/dracut.conf.d/99-root-key.conf > /dev/null
echo "/boot/ root:root 700" | sudo tee -a /etc/permissions.local
sudo chkstat --system --set
sudo mkinitrd

# Adding flathub repo 
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.discordapp.Discord org.DolphinEmu.dolphin-emu com.github.micahflee.torbrowser-launcher io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio

# Installing prime offload launchers
sudo cp ../dotfiles/prime-run /usr/bin
sudo chmod +x /usr/bin/prime-run

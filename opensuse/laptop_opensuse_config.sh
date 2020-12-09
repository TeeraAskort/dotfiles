#!/bin/bash

# Installing repos
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
sudo zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
sudo zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators

sudo zypper refresh

# Installing nvidia drivers
sudo OneClickInstallCLI https://www.opensuse-community.org/nvidia_G05.ymp

# Installing codecs
if [ $XDG_CURRENT_DESKTOP = "KDE" ]; then

	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-kde.ymp

	# Installing packages
	sudo zypper in chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions yakuake mpv elisa dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel qbittorrent emacs

else

	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-gnome.ymp

	# Installing packages
	sudo zypper in chromium steam lutris plata-theme papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions tilix mpv rhythmbox dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel emacs

fi

# Enabling thermald service
sudo systemctl enable thermald

# Adjusting sound quality
sudo sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sudo sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sudo sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sudo sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sudo sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf

# Adding flathub repo 
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.mojang.Minecraft com.discordapp.Discord

# Installing prime offload launchers
sudo cp ../dotfiles/prime-run /usr/bin
sudo chmod +x /usr/bin/prime-run

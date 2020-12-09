#!/bin/bash

# Installing repos
zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators

zypper refresh

# Installing nvidia drivers
OneClickInstallCLI https://www.opensuse-community.org/nvidia_G05.ymp

# Installing codecs
if [ $XDG_CURRENT_DESKTOP = "GNOME" ]; then
	# Installing codecs
	OneClickInstallCLI https://www.opensuse-community.org/codecs-gnome.ymp

	# Installing packages
	zypper in chromium steam lutris plata-theme papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions tilix mpv rhythmbox dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel

else
	# Installing codecs
	OneClickInstallCLI https://www.opensuse-community.org/codecs-kde.ymp

	# Installing packages
	zypper in chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions yakuake mpv elisa dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel qbittorrent

fi

# Enabling thermald service
systemctl enable thermald

# Adjusting sound quality
sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf

# Adding flathub repo 
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.mojang.Minecraft com.discordapp.Discord

# Installing prime offload launchers
cp prime-run /usr/bin
chmod +x /usr/bin/prime-run

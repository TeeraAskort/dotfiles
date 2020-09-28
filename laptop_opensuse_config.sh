#!/bin/bash

zypper in xf86-video-intel

# Installing repos
zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators

prime-select intel

zypper refresh

# Installing packages
zypper in chromium steam lutris metatheme-plata-common telegram-theme-plata papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions tilix mpv rhythmbox dolphin-emu discord telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel

# Adjusting sound quality
sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf

# Adding flathub repo 
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.mojang.Minecraft 

# Installing prime offload launchers
cp prime-run /usr/bin
chmod +x /usr/bin/prime-run

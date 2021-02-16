#!/bin/bash

# Installing required packages
eopkg it git steam lutris intel-undervolt curl zsh zsh-syntax-highlighting tilix discord telegram rhythmbox aisleriot kpat kmahjongg palapeli emacs vim wine wine-devel wine-32bit-devel winetricks nextcloud-client mpv flatpak xdg-desktop-portal-gtk

# Configuring pulseaudio
sudo sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /usr/share/pulseaudio/daemon.conf
sudo sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /usr/share/pulseaudio/daemon.conf
sudo sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /usr/share/pulseaudio/daemon.conf
sudo sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /usr/share/pulseaudio/daemon.conf
sudo sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /usr/share/pulseaudio/daemon.conf

# Restarting pulseaudio
pulseaudio -k

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing Minecraft
flatpak install flathub com.mojang.Minecraft

# Copying prime render offload launchers
cp prime* /usr/bin
chmod +x /usr/bin/prime*

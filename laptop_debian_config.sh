#!/bin/bash

#Enabling i386 support
dpkg --add-architecture i386
apt update

echo "Installing basic packages"
apt install mpv rhythmbox flatpak mednafen mednaffe dolphin-emu vim papirus-icon-theme zsh zsh-syntax-highlighting zsh-autosuggestions firmware-linux steam chromium nvidia-driver telegram-desktop nvidia-driver-libs:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386 libgl1:i386 mesa-vulkan-drivers:i386 mesa-vulkan-drivers neovim fonts-noto-cjk

#Installing lutris
echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | apt-key add -
apt-get update
apt-get install lutris

echo "Installing wine"
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
echo "deb https://dl.winehq.org/wine-builds/debian/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list
apt update && apt install winehq-staging winetricks

echo "Adjusting sound quality"
sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf
pulseaudio -k

echo "Installing flatpak applications"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.discordapp.Discord com.mojang.Minecraft com.katawa_shoujo.KatawaShoujo 

#Copying prime render offload launcher
cp prime-run /usr/bin
chmod +x /usr/bin/prime-run

#Copying xorg.conf
cp xorg.conf /etc/X11/xorg.conf

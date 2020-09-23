#!/bin/bash

# Installing required packages
sudo pacman -S tilix mpv rhythmbox jdk-openjdk dolphin-emu discord telegram-desktop flatpak code wine winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam

# Adjusting sound quality
sudo sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sudo sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sudo sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sudo sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sudo sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf

# Optimizing aur
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf

# Installing AUR packages
yay -S dxvk-bin aic94xx-firmware wd719x-firmware plata-theme-bin nerd-fonts-fantasque-sans-mono intel-undervolt gamemode lib32-gamemode

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install flathub com.mojang.Minecraft

echo GAMEMODERUNEXEC=prime-run | sudo tee -a /etc/environment

#!/bin/bash

# Installing required packages
sudo pacman -S tilix mpv rhythmbox jdk11-openjdk dolphin-emu discord telegram-desktop flatpak code wine winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam intellij-idea-community-edition thermald tlp earlyoom systembus-notify apparmor

# Enabling services
sudo systemctl enable thermald tlp earlyoom apparmor

# Add apparmor kernel paramenters
sudo sed -ie 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 apparmor=1 lsm=lockdown,yama,apparmor"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

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

# Configuring intel-undervolt
sudo sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf
sudo systemctl enable intel-undervolt

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install flathub com.mojang.Minecraft


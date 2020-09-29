#!/bin/bash

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flathub applications
flatpak install flathub org.telegram.desktop com.discordapp.Discord org.DolphinEmu.dolphin-emu com.jetbrains.IntelliJ-IDEA-Community com.google.AndroidStudio io.github.celluloid_player.Celluloid com.nextcloud.desktopclient.nextcloud org.gnome.Rhythmbox3

# Adding rpmfusion repos
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Installing packages
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks tilix

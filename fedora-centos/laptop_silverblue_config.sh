#!/bin/bash

# Adding repos
curl -L "https://copr.fedorainfracloud.org/coprs/alderaeney/plata-theme-master/repo/fedora-33/alderaeney-plata-theme-master-fedora-33.repo" > plata-theme-master.repo
curl -L "https://copr.fedorainfracloud.org/coprs/dawid/better_fonts/repo/fedora-33/dawid-better_fonts-fedora-33.repo" > better_fonts.repo
cp better_fonts.repo plata-theme-master.repo /etc/yum.repos.d/

# Updating the system
rpm-ostree upgrade

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Removing flatpaks from fedora repo
flatpak remove org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit

# Installing flatpaks from flathub repo
flatpak install flathub org.telegram.desktop com.discordapp.Discord org.DolphinEmu.dolphin-emu com.nextcloud.desktopclient.nextcloud com.transmissionbt.Transmission org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit org.libreoffice.LibreOffice com.valvesoftware.Steam org.gnome.Aisleriot org.gnome.Mahjongg com.github.Eloston.UngoogledChromium org.freedesktop.Piper com.github.micahflee.torbrowser-launcher com.google.AndroidStudio com.vscodium.codium org.gnome.Evolution org.jdownloader.JDownloader org.gimp.GIMP io.lbry.lbry-app com.mojang.Minecraft org.eclipse.Java

# Steam override
sudo -u link flatpak override --user --filesystem=/home/link/Datos/SteamLibrary com.valvesoftware.Steam

# Adding rpmfusion repos
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Installing packages
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks tilix intel-undervolt guayadeque guayadeque-langpack-es fontconfig-font-replacements fontconfig-enhanced-defaults openssl papirus-icon-theme net-tools libnsl plata-theme

# Adding intel_idle.max_cstate=1 kernel parameter
rpm-ostree kargs --append=intel_idle.max_cstate=1

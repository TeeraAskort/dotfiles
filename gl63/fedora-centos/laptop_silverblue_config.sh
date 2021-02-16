#!/bin/bash

# Adding repos
curl -L "https://copr.fedorainfracloud.org/coprs/dawid/better_fonts/repo/fedora-33/dawid-better_fonts-fedora-33.repo" > better_fonts.repo
cp better_fonts.repo /etc/yum.repos.d/

# Updating the system
rpm-ostree upgrade

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Removing flatpaks from fedora repo
flatpak remove org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit -y

# Installing flatpaks from flathub repo
flatpak install flathub org.telegram.desktop com.discordapp.Discord org.DolphinEmu.dolphin-emu com.nextcloud.desktopclient.nextcloud com.transmissionbt.Transmission org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit org.libreoffice.LibreOffice com.valvesoftware.Steam org.gnome.Aisleriot org.gnome.Mahjongg com.github.micahflee.torbrowser-launcher com.google.AndroidStudio com.vscodium.codium org.gnome.Evolution org.jdownloader.JDownloader org.gimp.GIMP io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio org.gnome.Boxes io.dbeaver.DBeaverCommunity com.getpostman.Postman -y

# Steam override
sudo -u link flatpak override --user --filesystem=/home/link/Datos/SteamLibrary com.valvesoftware.Steam

# Adding rpmfusion repos
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Installing packages
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks tilix intel-undervolt fontconfig-font-replacements fontconfig-enhanced-defaults openssl papirus-icon-theme net-tools libnsl tlp tlp-rdw java-1.8.0-openjdk-devel python-neovim cmake python3-devel nodejs npm gcc-c++

# Installing strawberry from official packages
curl -L "https://github.com/strawberrymusicplayer/strawberry/releases/download/0.8.5/strawberry-0.8.5-1.fc33.x86_64.rpm" > strawberry.rpm
rpm-ostree install ./strawberry.rpm

# Adding intel_idle.max_cstate=1 kernel parameter
rpm-ostree kargs --append=intel_idle.max_cstate=1

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf

#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

# Adding repos
curl -L "https://copr.fedorainfracloud.org/coprs/dawid/better_fonts/repo/fedora-35/dawid-better_fonts-fedora-35.repo" > better_fonts.repo
curl -L "https://copr.fedorainfracloud.org/coprs/ganto/lxc4/repo/fedora-35/ganto-lxc4-fedora-35.repo" > lxc4.repo
cp better_fonts.repo lxc4.repo virtualbox.repo /etc/yum.repos.d/
rm better_fonts.repo lxc4.repo virtualbox.repo

# Adding rpmfusion
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Updating the system
rpm-ostree upgrade

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo -u $user flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Adding flathub-beta repo
sudo -u $user flatpak remote-add --user flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

# Removing flatpaks from fedora repo
flatpak remove -y org.fedoraproject.MediaWriter org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit

# Installing flatpaks from flathub repo
flatpak install -y flathub org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit org.telegram.desktop com.discordapp.Discord com.transmissionbt.Transmission org.libreoffice.LibreOffice com.valvesoftware.Steam org.gnome.Aisleriot org.gnome.Mahjongg com.google.AndroidStudio com.visualstudio.code org.gnome.Evolution org.jdownloader.JDownloader org.gimp.GIMP io.lbry.lbry-app com.mojang.Minecraft com.obsproject.Studio io.dbeaver.DBeaverCommunity com.getpostman.Postman io.mpv.Mpv org.chromium.Chromium com.usebottles.bottles org.clementine_player.Clementine com.axosoft.GitKraken

# Steam library override
sudo -u $user flatpak override --user --filesystem=/home/link/Datos/SteamLibrary com.valvesoftware.Steam

# Installing flatpaks from flathub-beta repo
sudo -u $user flatpak install -y --user flathub-beta net.lutris.Lutris//beta
sudo -u $user flatpak install -y --user flathub org.gnome.Platform.Compat.i386 org.freedesktop.Platform.GL32.default org.freedesktop.Platform.GL.default

# Lutris library override
sudo -u $user flatpak override --user --filesystem=/home/link/Datos/Games net.lutris.Lutris

# Installing packages
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks intel-undervolt fontconfig-font-replacements fontconfig-enhanced-defaults lxd lxc papirus-icon-theme java-11-openjdk-devel protontricks patch dkms nodejs npm pam-u2f pamu2fcfg libva-intel-hybrid-driver google-noto-cjk-fonts google-noto-emoji-fonts webp-pixbuf-loader libnsl mod_perl 

# Installing xampp
until curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts


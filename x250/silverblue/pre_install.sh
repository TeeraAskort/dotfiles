#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

# Adding repos
curl -L "https://copr.fedorainfracloud.org/coprs/dawid/better_fonts/repo/fedora-35/dawid-better_fonts-fedora-35.repo" > better_fonts.repo
curl -L "https://copr.fedorainfracloud.org/coprs/ganto/lxc4/repo/fedora-35/ganto-lxc4-fedora-35.repo" > lxc4.repo
curl -LO "https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo"
cp better_fonts.repo lxc4.repo virtualbox.repo /etc/yum.repos.d/

# Adding rpmfusion
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Updating the system
rpm-ostree upgrade

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Removing flatpaks from fedora repo
flatpak remove 

# Installing flatpaks from flathub repo
flatpak install -y flathub org.telegram.desktop com.discordapp.Discord com.transmissionbt.Transmission org.libreoffice.LibreOffice com.valvesoftware.Steam org.gnome.Aisleriot org.gnome.Mahjongg com.google.AndroidStudio com.visualstudio.code org.gnome.Evolution org.jdownloader.JDownloader org.gimp.GIMP io.lbry.lbry-app com.mojang.Minecraft com.obsproject.Studio io.dbeaver.DBeaverCommunity com.getpostman.Postman io.mpv.Mpv org.chromium.Chromium com.usebottles.bottles org.clementine_player.Clementine com.axosoft.GitKraken

# Steam library override
sudo -u $user flatpak override --user --filesystem=/home/link/Datos/SteamLibrary com.valvesoftware.Steam

# Installing packages
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks intel-undervolt fontconfig-font-replacements fontconfig-enhanced-defaults lxd lxc papirus-icon-theme java-11-openjdk-devel unrar protontricks binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms VirtualBox-6.1 nodejs npm pam-u2f pamu2fcfg libva-intel-hybrid-driver zip unzip google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts libfido2 webp-pixbuf-loader ffmpegthumbnailer ffmpeg libnsl mod_perl 

# Enabling services
systemctl enable intel-undervolt

# Adding user to vboxusers group
usermod -aG vboxusers $user

# Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -75/g" /etc/intel-undervolt.conf

# Installing xampp
until curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts


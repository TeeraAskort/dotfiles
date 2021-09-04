#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

#DNF Tweaks
echo "deltarpm=true" | tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf 

#Setting up hostname
hostnamectl set-hostname link-pc

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Better font rendering cpor
dnf copr enable dawid/better_fonts -y

#Enabling mednaffe repo
dnf copr enable alderaeney/mednaffe -y

#Enabling xanmod repo
dnf copr enable rmnscnce/kernel-xanmod -y

#Enabling vivaldi repo
# dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo

#Install VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Upgrade system
dnf upgrade -y --refresh

#Install required packages
dnf install -y vim lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu fontconfig-enhanced-defaults fontconfig-font-replacements ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code aisleriot thermald gnome-mahjongg evolution python-neovim libfido2 strawberry chromium-freeworld mednafen mednaffe youtube-dl webp-pixbuf-loader materia-kde materia-gtk-theme brasero desmume kernel-xanmod-cacule unrar gimp mpv-mpris

systemctl enable thermald

# Remove unused packages 
dnf remove -y totem rhythmbox 

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y --allowerasing
dnf groupupdate sound-and-video -y

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf 

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app org.jdownloader.JDownloader org.telegram.desktop com.google.AndroidStudio 

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Add intel_idle.max_cstate=1 to grub and update
grubby --update-kernel=ALL --args='intel_idle.max_cstate=1'
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

#DNF Tweaks
echo "deltarpm=true" | tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf 

#Setting up hostname
hostnamectl set-hostname link-x250

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
dnf upgrade -y

#Install required packages
dnf install -y vim lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu fontconfig-enhanced-defaults fontconfig-font-replacements intel-undervolt ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code aisleriot thermald gnome-mahjongg evolution python-neovim libfido2 strawberry chromium-freeworld mednafen mednaffe youtube-dl webp-pixbuf-loader pam-u2f pamu2fcfg libva-intel-hybrid-driver materia-kde materia-gtk-theme acpid brasero desmume kernel-xanmod-cacule unrar

systemctl enable thermald acpid

# Remove unused packages 
dnf remove -y totem rhythmbox 

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y --allowerasing
dnf groupupdate sound-and-video -y

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf 

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -75/g" /etc/intel-undervolt.conf

systemctl enable intel-undervolt

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app com.google.AndroidStudio org.jdownloader.JDownloader org.gimp.GIMP org.telegram.desktop org.flarerpg.Flare com.mojang.Minecraft

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Add sysctl config
# echo "fs.inotify.max_user_watches=1048576" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing npm packages globally
npm i -g @ionic/cli @vue/cli 

# Headphone jack workaround
cp $directory/headphones /usr/local/bin
chmod +x /usr/local/bin/headphones

cp $directory/headphones.service /usr/lib/systemd/system/
cp $directory/headphones-sleep /usr/lib/systemd/system-sleep/
systemctl enable headphones.service

cp $directory/headphone_jack /etc/acpi/events
cp $directory/headphones /etc/acpi/actions
chmod +x /etc/acpi/actions/headphones

# Fix power button shutting down
sed -i "s/shutdown -h now/pm-suspend/g" /etc/acpi/actions/power.sh

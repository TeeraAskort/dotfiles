#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

#DNF Tweaks
echo "deltarpm=true" | tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf 
echo "fastestmirror=true" | tee -a /etc/dnf/dnf.conf

#Setting up hostname
hostnamectl set-hostname link-x250

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Better font rendering cpor
dnf copr enable dawid/better_fonts -y

#Add gnome-with-patches copr
dnf copr enable pp3345/gnome-with-patches -y

#Enabling google-chrome repo
dnf install fedora-workstation-repositories -y
dnf config-manager --set-enabled google-chrome

#Enabling xanmod kernel repo
dnf copr enable rmnscnce/kernel-xanmod -y

#Enabling mednaffe repo
dnf copr enable alderaeney/mednaffe -y

#Install VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Upgrade system
dnf upgrade -y

#Install required packages
dnf install -y vim tilix lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks dolphin-emu fontconfig-enhanced-defaults fontconfig-font-replacements intel-undervolt ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code java-11-openjdk-devel aisleriot thermald gnome-mahjongg piper evolution python-neovim cmake python3-devel nodejs npm gcc-c++ libfido2 strawberry NetworkManager-l2tp-gnome google-chrome-stable mednafen mednaffe youtube-dl kernel-xanmod-edge kernel-xanmod-edge-devel playerctl 

systemctl enable thermald 

# Remove unused packages 
dnf remove -y 

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
dnf groupupdate sound-and-video -y

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -75/g" /etc/intel-undervolt.conf

systemctl enable intel-undervolt

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app com.mojang.Minecraft com.google.AndroidStudio org.jdownloader.JDownloader org.gimp.GIMP com.obsproject.Studio com.getpostman.Postman com.jetbrains.IntelliJ-IDEA-Community com.bitwarden.desktop org.telegram.desktop com.slack.Slack com.anydesk.Anydesk io.dbeaver.DBeaverCommunity

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Add sysctl config
# echo "fs.inotify.max_user_watches=1048576" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing ionic
npm i -g @ionic/cli

# Headphone jack workaround
#cp $directory/headphones /usr/local/bin 
#chmod +x /usr/local/bin/headphones

#cp $directory/headphones.service /usr/lib/systemd/system/
#cp $directory/headphones-sleep /usr/lib/systemd/system-sleep/
#systemctl enable headphones.service

#cp $directory/headphone_jack /etc/acpi/events
#cp $directory/headphones /etc/acpi/actions
#chmod +x /etc/acpi/actions/headphones

# Fix power button shutting down
#sed -i "s/shutdown -h now/pm-suspend/g" /etc/acpi/actions/power.sh
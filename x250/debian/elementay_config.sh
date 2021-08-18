#!/usr/bin/env bash

## Installing software-properties for PPAs
apt install -y software-properties-common pkg-config

## Adding 32bit support
dpkg --add-architecture i386

## Adding PPAs
add-apt-repository ppa:kisak/kisak-mesa -y
add-apt-repository ppa:maarten-fonville/android-studio -y
add-apt-repository -y ppa:lutris-team/lutris
add-apt-repository -y ppa:philip.scott/pantheon-tweaks
add-apt-repository ppa:jonaski/strawberry -y
add-apt-repository ppa:papirus/papirus -y

## Updating the system
apt update
apt full-upgrade -y

## Installing nodejs
apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt-get update
apt-get install -y nodejs 

## Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
rm winehq.key
add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'
apt-get update
apt-get upgrade -y
apt-get install --install-recommends -y winehq-staging
apt-get install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386

## Installing required packages
apt install -y zsh zsh-syntax-highlighting zsh-autosuggestions libreoffice libreoffice-l10n-es firefox firefox-locale-es earlyoom thermald intel-microcode intel-media-va-driver mpv youtube-dl transmission-gtk vim neovim python3-neovim nano build-essential obs-studio desmume openjdk-11-jdk printer-driver-cups-pdf hplip fonts-noto fonts-noto-cjk fonts-noto-color-emoji mednaffe mednafen pamu2fcfg libpam-u2f hyphen-es hyphen-en-us gimp gstreamer1.0-vaapi gstreamer1.0-libav unrar zip unzip gamemode libfido2-1 mythes-en-us mythes-es hunspell-es hunspell-en-us pantheon-tweaks lutris libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 qemu-kvm libvirt0 android-studio-4.2 virt-manager strawberry gnome-mahjongg aisleriot evince gnome-system-monitor htop papirus-icon-theme

## Removing unwanted applications
apt remove -y io.elementary.videos noise vlc xterm

## Install outsider applications
curl -L "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > code.deb
curl -LO "https://lbry.com/get/lbry.deb"
curl -LO "https://launcher.mojang.com/download/Minecraft.deb"
apt install -y ./discord.deb ./steam.deb ./code.deb ./lbry.deb ./Minecraft.deb

## Installing npm packages globally
npm i -g @ionic/cli @vue/cli 

## Installing flatpak applications
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.jdownloader.JDownloader org.DolphinEmu.dolphin-emu com.katawa_shoujo.KatawaShoujo org.flarerpg.Flare org.chromium.Chromium org.telegram.desktop

## Removing flatpak applications
flatpak remove -y org.gnome.Epiphany io.elementary.tasks org.gnome.Evince

## Putting sysctl options
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

## Adding user to kvm group
user=$USER
sudo usermod -aG kvm $user

## Removing unused packages
apt autoremove -y --purge

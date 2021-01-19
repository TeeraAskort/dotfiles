#!/bin/bash

#Enabling i386 support
dpkg --add-architecture i386
apt update

#Installing basic packages
apt install ffmpegthumbnailer mpv flatpak mednafen mednaffe vim papirus-icon-theme zsh zsh-syntax-highlighting zsh-autosuggestions firmware-linux steam nvidia-driver telegram-desktop nvidia-driver-libs:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386 libgl1:i386 mesa-vulkan-drivers:i386 mesa-vulkan-drivers neovim fonts-noto-cjk openjdk-11-jdk nextcloud-desktop thermald intel-microcode gamemode tilix evolution

#Installing lutris
echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | apt-key add -
apt-get update
apt-get install lutris

#Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
echo "deb https://dl.winehq.org/wine-builds/debian/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list
apt update && apt install winehq-staging winetricks

# Installing outsider packages
curl -L "https://files.strawberrymusicplayer.org/strawberry_0.8.5-bullseye_amd64.deb" > strawberry.deb
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" > code.deb
apt install ./strawberry.deb ./code.deb

#Installing flatpak applications
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.discordapp.Discord org.DolphinEmu.dolphin-emu com.github.micahflee.torbrowser-launcher io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio

#Copying prime render offload launcher
cp ../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

# Adding intel_idle.max_cstate=1 to grub
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 intel_idle.max_cstate=1"/' /etc/default/grub
update-grub

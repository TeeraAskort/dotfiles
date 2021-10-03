#!/usr/bin/env bash

# Adding i386 support
dpkg --add-architecture i386

# Adding repositories
add-apt-repository ppa:lutris-team/lutris -y
add-apt-repository ppa:kisak/kisak-mesa -y
add-apt-repository ppa:ondrej/php -y

# Updating the system
apt update
apt full-upgrade -y

# Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'
apt update
apt full-upgrade -y
apt-get install --install-recommends -y winehq-staging
apt-get install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 \
libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386

# Installing required packages
apt install -y clementine mpv vim neovim python3-neovim zsh zsh-autosuggestions zsh-syntax-highlighting npm nodejs lxd flatpak telegram-desktop curl wget thermald earlyoom gamemode build-essential xz-utils openjdk-11-jdk pamu2fcfg net-tools fonts-noto-cjk aisleriot gnome-mahjongg transmission-gtk libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 apt-transport-https ffmpegthumbnailer hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us net-tools fonts-noto-color-emoji libfido2-1 libglu1-mesa libpam-u2f tlp mednafen mednaffe ffmpeg zip unzip unrar python3-mutagen rtmpdump phantomjs php8.0 composer

# Removing unwanted applications
apt remove -y gnome-mines quadrapassel gnome-sudoku pitivi rhythmbox totem

# Installing outsider applications
curl -L "https://discord.com/api/download?platform=linux&format=deb" > discord.deb
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
curl -LO "https://launcher.mojang.com/download/Minecraft.deb"
curl -L "https://github.com/lbryio/lbry-desktop/releases/download/v0.51.2/LBRY_0.51.2.deb?_ga=2.242496066.1377799971.1633284702-265872098.1633284702" > lbry.deb
apt install -y ./discord.deb ./steam.deb ./Minecraft.deb ./lbry.deb 
rm discord.deb steam.deb Minecraft.deb lbry.deb 

# Installing vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
apt update 
apt install code -y

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install -y flathub org.eclipse.Java com.axosoft.GitKraken org.jdownloader.JDownloader com.getpostman.Postman com.getpostman.Postman org.chromium.Chromium com.google.AndroidStudio

# Installing yt-dlp
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl

# Installing xampp
until curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts

# Removing uneeded packages
apt auto-remove --purge -y

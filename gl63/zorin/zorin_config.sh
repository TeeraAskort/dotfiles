#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Changing repository for a spanish one
sudo sed -i "s/es.archive.ubuntu.com/ftp.udc.es/g" /etc/apt/sources.list

# Adding i386 support
sudo dpkg --add-architecture i386

# Adding repositories
sudo add-apt-repository ppa:lutris-team/lutris -y
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:serge-rider/dbeaver-ce -y

# Updating the system
sudo apt update
sudo apt full-upgrade -y

# Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'
sudo apt update
sudo apt full-upgrade -y
sudo apt-get install --install-recommends -y winehq-staging
sudo apt-get install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 \
libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386
rm winehq.key

# Installing nodejs 16
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Disabling youtube-dl installation
sudo apt remove youtube-dl
sudo apt-mark hold youtube-dl
echo "Package: youtube-dl" | sudo tee -a /etc/apt/preferences
echo "Pin: release *" | sudo tee -a /etc/apt/preferences
echo "Pin-Priority: -1" | sudo tee -a /etc/apt/preferences
echo "" | sudo tee -a /etc/apt/preferences
sudo apt update

# Installing required packages
sudo apt install -y clementine mpv vim neovim python3-neovim zsh zsh-autosuggestions zsh-syntax-highlighting flatpak curl wget thermald earlyoom gamemode build-essential xz-utils openjdk-11-jdk net-tools fonts-noto-cjk aisleriot gnome-mahjongg transmission-gtk libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 apt-transport-https ffmpegthumbnailer hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us net-tools fonts-noto-color-emoji libfido2-1 libglu1-mesa mednafen mednaffe ffmpeg zip unzip unrar python3-mutagen rtmpdump phantomjs php8.0 composer chrome-gnome-shell hplip virtualbox virtualbox-dkms virtualbox-ext-pack lutris desmume filezilla printer-driver-cups-pdf f2fs-tools btrfs-progs exfat-fuse dbeaver-ce mariadb-server mariadb-client ttf-mscorefonts-installer libasound2-dev

# Removing unwanted applications
sudo apt remove -y gnome-mines quadrapassel gnome-sudoku pitivi rhythmbox totem 

# Install computer specific packages
sudo apt install -y intel-media-va-driver libpam-u2f tlp pamu2fcfg nvidia-driver-470 libvulkan1 libvulkan1:i386

# Installing mpv-mpris
sudo apt install -y libmpv-dev libglib2.0-dev
git clone https://github.com/hoyon/mpv-mpris.git
cd mpv-mpris
make 
sudo mkdir /etc/mpv/scripts
sudo cp mpris.so /etc/mpv/scripts
cd .. && sudo rm -r mpv-mpris
sudo apt remove -y libmpv-dev libglib2.0-dev

# Configuring mariadb
sudo mysql -u root -e "CREATE DATABASE farmcrash"
sudo mysql -u root -e "CREATE USER 'farmcrash'@localhost IDENTIFIED BY 'farmcrash'"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON farmcrash.* TO 'farmcrash'@localhost IDENTIFIED BY 'farmcrash'"

# Installing dotnet-sdk and OpenTabletDriver
curl -LO "https://github.com/OpenTabletDriver/OpenTabletDriver/releases/latest/download/OpenTabletDriver.deb"
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y apt-transport-https && sudo apt update && sudo apt install -y dotnet-sdk-5.0
sudo apt install -y ./OpenTabletDriver.deb
rm OpenTabletDriver.deb
systemctl --user daemon-reload
systemctl --user enable opentabletdriver --now

# Installing outsider applications
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
curl -LO "https://launcher.mojang.com/download/Minecraft.deb"
curl -L "https://github.com/lbryio/lbry-desktop/releases/download/v0.51.2/LBRY_0.51.2.deb?_ga=2.242496066.1377799971.1633284702-265872098.1633284702" > lbry.deb
sudo apt install -y ./steam.deb ./Minecraft.deb ./lbry.deb 
rm steam.deb Minecraft.deb lbry.deb 

# Installing vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
sudo apt update 
sudo apt install code -y

# Adding flathub repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install -y flathub org.eclipse.Java com.axosoft.GitKraken org.jdownloader.JDownloader com.getpostman.Postman org.chromium.Chromium com.google.AndroidStudio org.telegram.desktop com.discordapp.Discord

# Installing yt-dlp
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
sudo ln -s /usr/local/bin/yt-dlp /usr/bin/youtube-dl

# Installing xampp
until curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
sudo ./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | sudo tee -a /etc/hosts

# Installing lxd
sudo snap install lxd

# Setting up grub
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_idle.max_cstate=1"/' /etc/default/grub
sudo update-grub

# Removing uneeded packages
sudo apt autoremove --purge -y

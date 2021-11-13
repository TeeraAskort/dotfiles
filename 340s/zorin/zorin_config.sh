#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Changing repository for a spanish one
sed -i "s/es.archive.ubuntu.com/ftp.udc.es/g" /etc/apt/sources.list

# Adding i386 support
dpkg --add-architecture i386

# Adding repositories
add-apt-repository ppa:lutris-team/lutris -y
add-apt-repository ppa:kisak/kisak-mesa -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:serge-rider/dbeaver-ce -y
add-apt-repository ppa:papirus/papirus -y
add-apt-repository ppa:mc3man/mpv-tests -y
add-apt-repository ppa:jonaski/strawberry -y

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
rm winehq.key

# Installing nodejs 16
curl -fsSL https://deb.nodesource.com/setup_17.x | bash -
apt install -y nodejs

# Adding docker repo
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null


# Disabling youtube-dl installation
apt remove youtube-dl
apt-mark hold youtube-dl
echo "Package: youtube-dl" | tee -a /etc/apt/preferences
echo "Pin: release *" | tee -a /etc/apt/preferences
echo "Pin-Priority: -1" | tee -a /etc/apt/preferences
echo "" | tee -a /etc/apt/preferences
apt update

# Pre accepting licenses
echo "virtualbox-ext-pack virtualbox-ext-pack/license select true" | debconf-set-selections
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# Installing required packages
apt install -y strawberry mpv vim neovim python3-neovim zsh zsh-autosuggestions zsh-syntax-highlighting flatpak curl wget thermald earlyoom gamemode build-essential xz-utils openjdk-11-jdk fonts-noto-cjk aisleriot gnome-mahjongg transmission-gtk apt-transport-https ffmpegthumbnailer hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us fonts-noto-color-emoji libfido2-1 libglu1-mesa mednafen mednaffe ffmpeg zip unzip unrar python3-mutagen rtmpdump phantomjs composer chrome-gnome-shell hplip virtualbox virtualbox-dkms virtualbox-ext-pack lutris desmume filezilla printer-driver-cups-pdf f2fs-tools btrfs-progs exfat-fuse dbeaver-ce ttf-mscorefonts-installer libasound2-dev cryptsetup papirus-icon-theme neofetch pcsx2 docker-ce docker-ce-cli containerd.io docker-compose

# Removing unwanted applications
apt remove -y gnome-mines quadrapassel gnome-sudoku pitivi rhythmbox totem remmina

# Install computer specific packages
apt install -y intel-media-va-driver libvulkan1 libvulkan1:i386 libpam-fprintd libpam-u2f pamu2fcfg libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386

# Installing mpv-mpris
curl -LO "https://github.com/hoyon/mpv-mpris/releases/latest/download/mpris.so"
mkdir -p /etc/mpv/scripts
mv mpris.so /etc/mpv/scripts/mpris.so

# Installing outsider applications
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
curl -L "https://github.com/lbryio/lbry-desktop/releases/download/v0.51.2/LBRY_0.51.2.deb?_ga=2.242496066.1377799971.1633284702-265872098.1633284702" > lbry.deb
curl -L "https://release.gitkraken.com/linux/gitkraken-amd64.deb" > gitkraken.deb
apt install -y ./steam.deb ./lbry.deb ./gitkraken.deb 
rm steam.deb lbry.deb gitkraken.deb

# Installing vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
apt update 
apt install code -y

# Adding resume var to grub
part=$(blkid | grep swap | cut -d":" -f1)
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$(blkid -s UUID -o value $part)\"/" /etc/default/grub
update-grub
echo "RESUME=UUID=$(blkid -s UUID -o value $part)" | tee -a /etc/initramfs-tools/conf.d/resume
update-initramfs -c -k all

# Copying hibernation config
cp $directory/../common/hibernate-gnome.pkla /etc/polkit-1/localauthority/50-local.d/hibernate.pkla

# Setting logind.conf hibernate settings
echo "HandleLidSwitch=hibernate" | tee -a /etc/systemd/logind.conf 
echo "HandleLidSwitchExternalPower=hibernate" | tee -a /etc/systemd/logind.conf
echo "HandleLidSwitchDocked=hibernate" | tee -a /etc/systemd/logind.conf
echo "IdleAction=hibernate" | tee -a /etc/systemd/logind.conf
echo "IdleActionSec=15min" | tee -a /etc/systemd/logind.conf

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install -y flathub org.jdownloader.JDownloader com.getpostman.Postman org.telegram.desktop com.discordapp.Discord com.jetbrains.PhpStorm org.chromium.Chromium com.google.AndroidStudio io.gdevs.GDLauncher io.github.sharkwouter.Minigalaxy

# Installing yt-dlp
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
ln -s /usr/local/bin/yt-dlp /usr/bin/youtube-dl

# Installing eclipse
curl -L "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2021-09/R/eclipse-jee-2021-09-R-linux-gtk-x86_64.tar.gz" > eclipse-jee.tar.gz
tar xzvf eclipse-jee.tar.gz -C /opt
rm eclipse-jee.tar.gz
desktop-file-install $directory/../../common/eclipse.desktop

# Adding user to docker group
user="$SUDO_USER"
usermod -aG docker $user

# Removing uneeded packages
apt autoremove --purge -y

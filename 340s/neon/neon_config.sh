#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Changing repository for a spanish one
sed -i "s/archive.ubuntu.com/ftp.udc.es/g" /etc/apt/sources.list

# Adding i386 support
dpkg --add-architecture i386

# Adding repositories
add-apt-repository ppa:lutris-team/lutris -y
add-apt-repository ppa:kisak/kisak-mesa -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:serge-rider/dbeaver-ce -y
add-apt-repository ppa:papirus/papirus -y

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
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs

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
apt install -y clementine mpv vim neovim python3-neovim zsh zsh-autosuggestions zsh-syntax-highlighting flatpak curl wget thermald earlyoom gamemode build-essential xz-utils openjdk-11-jdk net-tools fonts-noto-cjk libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 apt-transport-https hunspell-es hunspell-en-us aspell-es aspell-en mythes-es mythes-en-us net-tools fonts-noto-color-emoji libfido2-1 libglu1-mesa mednafen mednaffe ffmpeg zip unzip unrar python3-mutagen rtmpdump phantomjs php8.0 composer hplip virtualbox virtualbox-dkms virtualbox-ext-pack lutris desmume filezilla printer-driver-cups-pdf f2fs-tools btrfs-progs exfat-fuse dbeaver-ce mariadb-server mariadb-client ttf-mscorefonts-installer libasound2-dev tilix cryptsetup libreoffice libreoffice-qt5 gnome-keyring palapeli kpat qbittorrent thunderbird thunderbird-locale-es-es yakuake ffmpegthumbs okular-backends okular-extra-backends kdeconnect k3b k3b-i18n kio-audiocd kio-extras kio-smtp kio-gdrive papirus-icon-theme kate 

# Install computer specific packages
apt install -y intel-media-va-driver tlp libvulkan1 libvulkan1:i386 libpam-fprintd libpam-u2f pamu2fcfg

# Removing unwanted packages
apt remove -y vlc

# Installing mpv-mpris
apt install -y libmpv-dev libglib2.0-dev
git clone https://github.com/hoyon/mpv-mpris.git
cd mpv-mpris
make
mkdir /etc/mpv/scripts
cp mpris.so /etc/mpv/scripts
cd .. && rm -r mpv-mpris
apt remove -y libmpv-dev libglib2.0-dev

# Installing outsider applications
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
curl -LO "https://launcher.mojang.com/download/Minecraft.deb"
curl -L "https://github.com/lbryio/lbry-desktop/releases/download/v0.51.2/LBRY_0.51.2.deb?_ga=2.242496066.1377799971.1633284702-265872098.1633284702" > lbry.deb
apt install -y ./steam.deb ./Minecraft.deb ./lbry.deb
rm steam.deb Minecraft.deb lbry.deb

# Adding GTK_USE_PORTAL
echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

# Adding gnome-keyring settings
cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
if diff /etc/pam.d/sddm.bak sddm; then
	awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth     optional       pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
	cp sddm /etc/pam.d/sddm
else
	sudo cp sddm /etc/pam.d/sddm
fi
rm sddm
cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
if diff /etc/pam.d/sddm.bak sddm; then
	awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session  optional       pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm >sddm
	cp sddm /etc/pam.d/sddm
else
	sudo cp sddm /etc/pam.d/sddm
fi
rm sddm

# Adding gnome-keyring to passwd pam setings
echo "password	optional	pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

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
flatpak install -y flathub org.eclipse.Java com.axosoft.GitKraken org.jdownloader.JDownloader com.getpostman.Postman org.chromium.Chromium com.google.AndroidStudio org.telegram.desktop com.discordapp.Discord

# Installing yt-dlp
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
ln -s /usr/local/bin/yt-dlp /usr/bin/youtube-dl

# Adding resume var to grub
part=$(blkid | grep swap | cut -d":" -f1)
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$(blkid -s UUID -o value $part)\"/" /etc/default/grub
update-grub
echo "RESUME=UUID=$(blkid -s UUID -o value $part)" | tee -a /etc/initramfs-tools/conf.d/resume
update-initramfs -c -k all

# Copying polkit rules
cp $directory/hibernate.pkla /etc/polkit-1/localauthority/50-local.d/hibernate.pkla

# Adding systemd overriding of power settings
# echo "AllowHibernation=yes" | tee -a /etc/systemd/sleep.conf
# echo "HibernateState=disk" | tee -a /etc/systemd/sleep.conf

# Installing xampp
ver="8.0.11"
until curl -L "https://www.apachefriends.org/xampp-files/${ver}/xampp-linux-x64-${ver}-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts

# Removing uneeded packages
apt autoremove --purge -y

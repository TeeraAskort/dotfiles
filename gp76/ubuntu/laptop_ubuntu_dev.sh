#!/usr/bin/env bash

if !command -v nvidia-smi &> /dev/null ; then
	bash ./first_boot.sh
	exit
fi

# Installing cuda
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
dpkg -i cuda-keyring_1.0-1_all.deb
apt-get update
apt-get -y install cuda tensorrt-libs tensorrt-dev

## Installing wine
apt install -y wine64 wine32 libasound2-plugins:i386 libsdl2-2.0-0:i386 libdbus-1-3:i386 libsqlite3-0:i386

## Installing strawberry
add-apt-repository ppa:jonaski/strawberry -y
apt update
apt install -y strawberry

## Installing firefox correctly
snap remove firefox
add-apt-repository ppa:mozillateam/ppa -y
cat >/etc/apt/preferences.d/mozillateamppa <<EOF
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501
EOF
apt update
apt install -t 'o=LP-PPA-mozillateam' -y firefox firefox-locale-es

## Installing steam
curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
apt install -y ./steam.deb
rm steam.deb

## Installing Google Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >>/etc/apt/sources.list.d/google-chrome.list
apt update
apt install -y google-chrome-stable

## Installing Nicotine+
add-apt-repository ppa:nicotine-team/stable -y
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6CEB6050A30E5769
apt update
apt install -y nicotine

## Holding youtube-dl
apt-mark hold youtube-dl

## Installing VSCode
apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" >/etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
apt update
apt install -y code

## Installing openrazer drivers
add-apt-repository ppa:openrazer/stable -y
apt update
apt install -y openrazer-meta

## Installing razergenie
echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/hardware:razer.list
curl -fsSL https://download.opensuse.org/repositories/hardware:razer/xUbuntu_20.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/hardware_razer.gpg > /dev/null
apt update
apt install -y razergenie

## Pre accepting licenses
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

## Installing multimedia codecs
add-apt-repository multiverse -y
apt-get install -y ubuntu-restricted-extras

## Installing nodejs
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - &&\
apt-get install -y nodejs

## Installing python anaconda
curl -L "https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh" > conda.sh
bash conda.sh -b -p /opt/anaconda
rm -f conda.sh

## Installing heroic games launcher
bash <(wget -qO- https://raw.githubusercontent.com/Heroic-Games-Launcher/HeroicGamesLauncher/main/rauldipeas.sh)

## Installing R language
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
apt update
apt install -y r-base

## Installing required packages
apt install -y flatpak mpv zsh zsh-autosuggestions zsh-syntax-highlighting fonts-noto-cjk fonts-noto-color-emoji gamemode gparted vim neovim python3-neovim libfido2-1 mednafen mednaffe nextcloud-desktop pcsx2 zram-config gimp cups printer-driver-cups-pdf hplip libreoffice hunspell-en-us hunspell-es hunspell-ca aspell-ca aspell-es mythes-en-us mythes-es mythes-ca hyphen-en-us hyphen-es hyphen-ca zip unzip unrar p7zip lzop pigz pbzip2 bash-completion cryptsetup ntfs-3g neofetch yt-dlp thermald earlyoom solaar piper openjdk-17-jdk

## Enabling services
systemctl enable thermald earlyoom

## Installing computer specific applications
apt install -y intel-microcode pamu2fcfg libpam-u2f

## Adding user to plugdev group
user="$SUDO_USER"
usermod -aG plugdev $user

## Configuring flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Installing flatpak applications
flatpak install -y flathub com.getpostman.Postman org.telegram.desktop org.jdownloader.JDownloader com.obsproject.Studio org.DolphinEmu.dolphin-emu com.jetbrains.PyCharm-Community net.lutris.Lutris

## Putting this option for the chrome-sandbox bullshit
echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

## Decrease swappiness
echo "vm.swappiness = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.vfs_cache_pressure = 50" | tee -a /etc/sysctl.d/99-sysctl.conf

## Virtual memory tuning
echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

# Optimize SSD and HDD performance
cat >/etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

## Installing desktop specific packages
apt install -y adwaita-qt gedit gvfs-backends aisleriot gnome-mahjongg ffmpegthumbnailer evolution deluge deluge-gtk evince simple-scan xdg-desktop-portal-gtk brasero libopenraw7 libgsf-1-114 libgepub-0.6-0 gthumb file-roller gnome-boxes chrome-gnome-shell gnome-photos gnome-keyring gnome-calculator gnome-tweaks chrome-gnome-shell

## Removing desktop specific packages
# apt remove -y

# Disabling wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm/custom.conf

# Adding gnome theming to qt
echo "QT_STYLE_OVERRIDE=adwaita-dark" | tee -a /etc/environment

## Removing unused packages
apt autoremove -y

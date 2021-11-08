#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

#DNF Tweaks
echo "deltarpm=true" | tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf 

#Setting up hostname
hostnamectl set-hostname link-340s

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Installing tainted repos
dnf in -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted

#Enabling mednaffe repo
dnf copr enable alderaeney/mednaffe -y

#Enabling vivaldi repo
# dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo

#Install VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Upgrade system
dnf upgrade -y --refresh 

# Wine dependencies
dnf install -y alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel libgcc.i686 libX11-devel.i686 freetype-devel.i686 libXcursor-devel.i686 libXi-devel.i686 libXext-devel.i686 libXxf86vm-devel.i686 libXrandr-devel.i686 libXinerama-devel.i686 mesa-libGLU-devel.i686 mesa-libOSMesa-devel.i686 libXrender-devel.i686 libpcap-devel.i686 ncurses-devel.i686 libzip-devel.i686 lcms2-devel.i686 zlib-devel.i686 libv4l-devel.i686 libgphoto2-devel.i686 cups-devel.i686 libxml2-devel.i686 openldap-devel.i686 libxslt-devel.i686 gnutls-devel.i686 libpng-devel.i686 flac-libs.i686 json-c.i686 libICE.i686 libSM.i686 libXtst.i686 libasyncns.i686 liberation-narrow-fonts.noarch libieee1284.i686 libogg.i686 libsndfile.i686 libuuid.i686 libva.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 llvm-libs.i686 mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libgbm.i686 nss-mdns.i686 ocl-icd.i686 pulseaudio-libs.i686 sane-backends-libs.i686 tcp_wrappers-libs.i686 unixODBC.i686 samba-common-tools.x86_64 samba-libs.x86_64 samba-winbind.x86_64 samba-winbind-clients.x86_64 samba-winbind-modules.x86_64 mesa-libGL-devel.i686 fontconfig-devel.i686 libXcomposite-devel.i686 libtiff-devel.i686 openal-soft-devel.i686 mesa-libOpenCL-devel.i686 opencl-utils-devel.i686 alsa-lib-devel.i686 gsm-devel.i686 libjpeg-turbo-devel.i686 pulseaudio-libs-devel.i686 pulseaudio-libs-devel gtk3-devel.i686 libattr-devel.i686 libva-devel.i686 libexif-devel.i686 libexif.i686 glib2-devel.i686 mpg123-devel.i686 mpg123-devel.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libFAudio-devel.i686 libFAudio-devel.x86_64

sudo dnf groupinstall "C Development Tools and Libraries" -y
sudo dnf groupinstall "Development Tools" -y

#Install required packages
dnf install -y vim lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code aisleriot thermald gnome-mahjongg evolution python-neovim libfido2 strawberry chromium-freeworld mednafen mednaffe webp-pixbuf-loader brasero desmume unrar gimp mpv-mpris protontricks libnsl mod_perl java-11-openjdk-devel ffmpeg rtmpdump aria2 AtomicParsley dkms elfutils-libelf-devel qt5-qtx11extras VirtualBox gtk-murrine-engine gtk2-engines kernel-headers kernel-devel discord pcsx2 mariadb-server neofetch httpd php php-common php-mysqlnd php-xml php-json php-gd php-mbstring unzip zip cryptsetup alsa-plugins-pulseaudio.x86_64 alsa-lib-devel.x86_64 nicotine+ file-roller composer materia-gtk-theme materia-kde

# Enabling services
systemctl enable thermald mariadb httpd

# Starting services
systemctl start mariadb httpd

# Adding user to vboxusers group
user="$SUDO_USER"
usermod -aG vboxusers $user 

# Installing computer specific packages
dnf in -y pam-u2f pamu2fcfg libva-intel-hybrid-driver 

# Remove unused packages 
dnf remove -y totem rhythmbox 

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y --allowerasing
dnf groupupdate sound-and-video -y

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf 

# Configuring hibernate
mkdir -p /etc/dracut.conf.d
echo "add_dracutmodules+=\" resume \"" | tee -a /etc/dracut.conf.d/resume.conf
dracut -f
echo "AllowHibernation=yes" | tee -a /etc/systemd/sleep.conf
echo "HibernateMode=shutdown" | tee -a /etc/systemd/sleep.conf
echo "HandleLidSwitch=hibernate" | tee -a /etc/systemd/logind.conf
echo "HandleLidSwitchExternalPower=hibernate" | tee -a /etc/systemd/logind.conf
echo "IdleAction=hibernate" | tee -a /etc/systemd/logind.conf
echo "IdleActionSec=15min" | tee -a /etc/systemd/logind.conf

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub io.lbry.lbry-app org.jdownloader.JDownloader org.telegram.desktop com.axosoft.GitKraken com.getpostman.Postman io.dbeaver.DBeaverCommunity org.gtk.Gtk3theme.Adwaita-dark com.jetbrains.PhpStorm com.google.AndroidStudio io.gdevs.GDLauncher

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Setting hostname properly for apache
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts

# Configuring apache
firewall-cmd --add-service=http --add-service=https --permanent
firewall-cmd --reload

# Copying php project
cd /var/www/html
git clone https://TeeraAskort@github.com/TeeraAskort/projecte-php.git
chown -R link:users projecte-php
chmod -R 755 projecte-php

# Overriding phpstorm config
user="$SUDO_USER"
sudo -u $user flatpak override --user --filesystem=/var/www/html com.jetbrains.PhpStorm

# Installing yt-dlp
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
ln -s /usr/local/bin/yt-dlp /usr/bin/youtube-dl

# Installing eclipse
curl -L "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2021-09/R/eclipse-jee-2021-09-R-linux-gtk-x86_64.tar.gz" > eclipse-jee.tar.gz
tar xzvf eclipse-jee.tar.gz -C /opt
rm eclipse-jee.tar.gz
desktop-file-install $directory/../common/eclipse.desktop

# Adding sound input & output device chooser
user="$SUDO_USER"
sudo -u $user mkdir -p /home/$user/.local/share/gnome-shell/extensions/
cd /home/$user/.local/share/gnome-shell/extensions/
sudo -u $user git clone https://github.com/kgshank/gse-sound-output-device-chooser.git
sudo -u $user cp -r gse-sound-output-device-chooser/sound-output-device-chooser@kgshank.net .
sudo -u $user rm -rf "gse-sound-output-device-chooser"

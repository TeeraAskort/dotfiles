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

#Enabling lxc repo
dnf copr enable ganto/lxc4 -y

#Enabling vivaldi repo
# dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo

#Install VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Upgrade system
dnf upgrade -y --refresh

# Wine dependencies
sudo dnf install -y alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel libgcc.i686 libX11-devel.i686 freetype-devel.i686 libXcursor-devel.i686 libXi-devel.i686 libXext-devel.i686 libXxf86vm-devel.i686 libXrandr-devel.i686 libXinerama-devel.i686 mesa-libGLU-devel.i686 mesa-libOSMesa-devel.i686 libXrender-devel.i686 libpcap-devel.i686 ncurses-devel.i686 libzip-devel.i686 lcms2-devel.i686 zlib-devel.i686 libv4l-devel.i686 libgphoto2-devel.i686 cups-devel.i686 libxml2-devel.i686 openldap-devel.i686 libxslt-devel.i686 gnutls-devel.i686 libpng-devel.i686 flac-libs.i686 json-c.i686 libICE.i686 libSM.i686 libXtst.i686 libasyncns.i686 liberation-narrow-fonts.noarch libieee1284.i686 libogg.i686 libsndfile.i686 libuuid.i686 libva.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 llvm-libs.i686 mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libgbm.i686 nss-mdns.i686 ocl-icd.i686 pulseaudio-libs.i686 sane-backends-libs.i686 tcp_wrappers-libs.i686 unixODBC.i686 samba-common-tools.x86_64 samba-libs.x86_64 samba-winbind.x86_64 samba-winbind-clients.x86_64 samba-winbind-modules.x86_64 mesa-libGL-devel.i686 fontconfig-devel.i686 libXcomposite-devel.i686 libtiff-devel.i686 openal-soft-devel.i686 mesa-libOpenCL-devel.i686 opencl-utils-devel.i686 alsa-lib-devel.i686 gsm-devel.i686 libjpeg-turbo-devel.i686 pulseaudio-libs-devel.i686 pulseaudio-libs-devel gtk3-devel.i686 libattr-devel.i686 libva-devel.i686 libexif-devel.i686 libexif.i686 glib2-devel.i686 mpg123-devel.i686 mpg123-devel.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libFAudio-devel.i686 libFAudio-devel.x86_64

sudo dnf groupinstall "C Development Tools and Libraries" -y
sudo dnf groupinstall "Development Tools" -y

#Install required packages
dnf install -y vim lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu fontconfig-enhanced-defaults fontconfig-font-replacements ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code aisleriot thermald gnome-mahjongg evolution python-neovim libfido2 clementine chromium-freeworld mednafen mednaffe webp-pixbuf-loader brasero desmume kernel-xanmod-edge kernel-xanmod-edge-devel kernel-xanmod-edge-headers unrar gimp mpv-mpris protontricks libnsl mod_perl java-11-openjdk-devel lxd lxc ffmpeg rtmpdump aria2 AtomicParsley dkms elfutils-libelf-devel qt5-qtx11extras VirtualBox gtk-murrine-engine gtk2-engines

systemctl enable thermald 

# Adding user to vboxusers group
user="$SUDO_USER"
usermod -aG vboxusers $user 

# Installing computer specific packages
dnf in -y pam-u2f pamu2fcfg libva-intel-hybrid-driver acpid intel-undervolt

# Enabling services
systemctl enable acpid intel-undervolt

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

#Installing qogir theme
curl -L "https://api.github.com/repos/vinceliuice/Qogir-theme/tarball" > Qogir-gtk.tar.gz
tar xzvf Qogir-gtk.tar.gz && cd *Qogir-theme*
./install.sh -l fedora -c dark -w square
cd .. && rm -r *Qogir*
git clone https://github.com/vinceliuice/Qogir-kde.git
cd Qogir-kde
./install.sh
cd .. && rm -r Qogir-kde

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app com.google.AndroidStudio org.jdownloader.JDownloader org.telegram.desktop org.eclipse.Java com.axosoft.GitKraken com.mojang.Minecraft com.getpostman.Postman io.dbeaver.DBeaverCommunity

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Add sysctl config
# echo "fs.inotify.max_user_watches=1048576" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing xampp
until curl -L "https://www.apachefriends.org/xampp-files/8.0.10/xampp-linux-x64-8.0.10-0-installer.run" > xampp.run; do
	echo "Retrying"
done
chmod 755 xampp.run
./xampp.run --unattendedmodeui minimal --mode unattended
rm xampp.run

# Setting hostname properly for xampp
echo "127.0.0.1    $(hostname)" | tee -a /etc/hosts

# Installing yt-dlp
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl

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

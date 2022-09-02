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

# Enabling touchegg repo
# dnf copr enable jose_exposito/touchegg -y

# Enabling better_fonts repo
dnf copr enable hyperreal/better_fonts -y

#Enabling vivaldi repo
# dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo

#Adding brave repo
# dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
# rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Adding openrazer repos
dnf config-manager --add-repo https://download.opensuse.org/repositories/hardware:razer/Fedora_35/hardware:razer.repo

# Input remapper copr repo
dnf copr enable sunwire/input-remapper -y

# Heroic games launcher repo
dnf copr enable atim/heroic-games-launcher -y

# Adding docker repo
# dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

#Install VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Installing xanmod kernel
dnf copr enable rmnscnce/kernel-xanmod -y
dnf in -y kernel-xanmod-edge kernel-xanmod-edge-devel kernel-xanmod-edge-headers

# Upgrade system
dnf upgrade -y --refresh

# Wine dependencies
dnf install -y alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel libgcc.i686 libX11-devel.i686 freetype-devel.i686 libXcursor-devel.i686 libXi-devel.i686 libXext-devel.i686 libXxf86vm-devel.i686 libXrandr-devel.i686 libXinerama-devel.i686 mesa-libGLU-devel.i686 mesa-libOSMesa-devel.i686 libXrender-devel.i686 libpcap-devel.i686 ncurses-devel.i686 libzip-devel.i686 lcms2-devel.i686 zlib-devel.i686 libv4l-devel.i686 libgphoto2-devel.i686 cups-devel.i686 libxml2-devel.i686 openldap-devel.i686 libxslt-devel.i686 gnutls-devel.i686 libpng-devel.i686 flac-libs.i686 json-c.i686 libICE.i686 libSM.i686 libXtst.i686 libasyncns.i686 liberation-narrow-fonts.noarch libieee1284.i686 libogg.i686 libsndfile.i686 libuuid.i686 libva.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 llvm-libs.i686 mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libgbm.i686 nss-mdns.i686 ocl-icd.i686 pulseaudio-libs.i686 sane-backends-libs.i686 tcp_wrappers-libs.i686 unixODBC.i686 samba-common-tools.x86_64 samba-libs.x86_64 samba-winbind.x86_64 samba-winbind-clients.x86_64 samba-winbind-modules.x86_64 mesa-libGL-devel.i686 fontconfig-devel.i686 libXcomposite-devel.i686 libtiff-devel.i686 openal-soft-devel.i686 mesa-libOpenCL-devel.i686 opencl-utils-devel.i686 alsa-lib-devel.i686 gsm-devel.i686 libjpeg-turbo-devel.i686 pulseaudio-libs-devel.i686 pulseaudio-libs-devel gtk3-devel.i686 libattr-devel.i686 libva-devel.i686 libexif-devel.i686 libexif.i686 glib2-devel.i686 mpg123-devel.i686 mpg123-devel.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libFAudio-devel.i686 libFAudio-devel.x86_64

dnf groupinstall "C Development Tools and Libraries" -y
dnf groupinstall "Development Tools" -y

#Install required packages
dnf install -y vim lutris steam mpv mpv-mpris flatpak zsh zsh-syntax-highlighting papirus-icon-theme wine winetricks gnome-tweaks dolphin-emu ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code aisleriot thermald gnome-mahjongg geary python-neovim libfido2 strawberry mednafen mednaffe webp-pixbuf-loader brasero desmume unrar gimp protontricks java-11-openjdk-devel ffmpeg pcsx2 neofetch unzip zip cryptsetup alsa-plugins-pulseaudio.x86_64 alsa-lib-devel.x86_64 nicotine+ file-roller yt-dlp p7zip razergenie openrazer-meta nextcloud-client google-chrome-stable sqlite deluge deluge-gtk obs-studio seahorse fontconfig-font-replacements fontconfig-enhanced-defaults hunspell-ca hunspell-es-ES mythes-ca mythes-es mythes-en hyphen-es hyphen-ca hyphen-en aspell-ca aspell-es aspell-en android-tools piper redhat-lsb-core solaar zpaq python3-input-remapper heroic-games-launcher-bin

# Installing docker
# dnf in -y docker-ce docker-ce-cli containerd.io docker-compose
# systemctl enable --now docker

# Enabling services
user="$SUDO_USER"
systemctl enable thermald input-remapper

# Adding user to plugdev group
user="$SUDO_USER"
usermod -aG plugdev $user

# Adding user to docker group
# user="$SUDO_USER"
# usermod -aG docker $user

# Installing mongodb compass
# dnf in -y "https://github.com/mongodb-js/compass/releases/download/v1.32.6/mongodb-compass-1.32.6.x86_64.rpm"

# Installing computer specific packages
dnf in -y pam-u2f pamu2fcfg libva-intel-hybrid-driver # touchegg

# Remove unused packages
dnf remove -y totem rhythmbox

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate sound-and-video -y
dnf install -y libdvdcss
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
dnf install -y lame\* --exclude=lame-devel
dnf group upgrade -y --with-optional Multimedia

# Install nvidia drivers
dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
cat > /etc/modprobe.d/nvidia.conf <<EOF
# Enable DynamicPwerManagement
# http://download.nvidia.com/XFree86/Linux-x86_64/440.31/README/dynamicpowermanagement.html
options nvidia NVreg_DynamicPowerManagement=0x02
EOF

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub org.jdownloader.JDownloader org.gtk.Gtk3theme.Adwaita-dark sh.ppy.osu com.discordapp.Discord org.telegram.desktop

# Installing yt-dlp
ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl

# Setting intel performance options
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Decrease swappiness
echo "vm.swappiness=1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.vfs_cache_pressure=50" | tee -a /etc/sysctl.d/99-sysctl.conf

# Virtual memory tuning
echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

# Kernel hardening
echo "kernel.kptr_restrict = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "net.core.bpf_jit_harden=2" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "kernel.kexec_load_disabled = 1" | tee -a /etc/sysctl.d/99-sysctl.conf

# Optimize SSD and HDD performance
cat > /etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

# Fixing font rendering
# cp $directory/local.conf /etc/fonts/local.conf

# Adding ssh-askpass env var
echo "SSH_ASKPASS=/usr/libexec/seahorse/ssh-askpass" | tee -a /etc/environment

# Copying prime-run
cp $directory/../dotfiles/prime-run /usr/bin

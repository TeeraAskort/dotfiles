#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

#DNF Tweaks
echo "deltarpm=true" | tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf 

#Setting up hostname
hostnamectl set-hostname link-gl63-8rc

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Better font rendering cpor
dnf copr enable dawid/better_fonts -y

#Add gnome-with-patches copr
dnf copr enable pp3345/gnome-with-patches -y

#Enabling mednaffe repo
dnf copr enable alderaeney/mednaffe -y

#Enabling vivaldi repo
dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo

#Install VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Upgrade system
dnf upgrade -y

#Install required packages
dnf install -y vim lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu pcsx2 fontconfig-enhanced-defaults fontconfig-font-replacements intel-undervolt ffmpegthumbnailer zsh-autosuggestions google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code aisleriot thermald gnome-mahjongg evolution python-neovim libfido2 strawberry chromium-freeworld mednafen mednaffe youtube-dl pam-u2f pamu2fcfg libva-intel-hybrid-driver materia-gtk-theme materia-kde vivaldi-stable

systemctl enable thermald

# Remove unused packages 
dnf remove -y totem rhythmbox firefox

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y --allowerasing
dnf groupupdate sound-and-video -y

#Install nvidia drivers
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
cat > /etc/modprobe.d/nvidia.conf <<EOF
# Enable DynamicPwerManagement
# http://download.nvidia.com/XFree86/Linux-x86_64/440.31/README/dynamicpowermanagement.html
options nvidia NVreg_DynamicPowerManagement=0x02
EOF


#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf 

#Copying PRIME render offload launcher
cp $directory/../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

systemctl enable intel-undervolt

# Changing tlp config
# sed -i "s/#CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_power/g" /etc/tlp.conf
# sed -i "s/#SCHED_POWERSAVE_ON_AC=0/SCHED_POWERSAVE_ON_AC=1/g" /etc/tlp.conf

# systemctl enable tlp

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app com.google.AndroidStudio org.jdownloader.JDownloader org.gimp.GIMP org.telegram.desktop 

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Add sysctl config
# echo "fs.inotify.max_user_watches=1048576" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing ionic
npm i -g @ionic/cli

# Installing firebase cli
npm install -g firebase-tools

# Add intel_idle.max_cstate=1 to grub and update
grubby --update-kernel=ALL --args='intel_idle.max_cstate=1'
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

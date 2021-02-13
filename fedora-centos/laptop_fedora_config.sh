#!/bin/bash

user=$SUDO_USER

# Add fastestmirror to dnf configuration
echo "fastestmirror=1" | tee -a /etc/dnf/dnf.conf

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Better font rendering cpor
dnf copr enable dawid/better_fonts -y

#Add gnome-with-patches copr
dnf copr enable pp3345/gnome-with-patches -y

#Install VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo

# Upgrade system
dnf upgrade -y

#Install required packages
dnf install -y vim tilix telegram-desktop lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu pcsx2 fontconfig-enhanced-defaults fontconfig-font-replacements intel-undervolt ffmpegthumbnailer zsh-autosuggestions chromium-freeworld google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts nodejs npm code java-11-openjdk-devel aisleriot thermald gnome-mahjongg piper evolution net-tools libnsl tlp python-neovim cmake python3-devel nodejs npm gcc-c++ sqlitebrowser pam-u2f libfido2 pamu2fcfg clang cargo cryptsetup-devel

systemctl enable thermald

# Remove unused packages 
dnf remove -y totem

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
dnf groupupdate sound-and-video -y

#Install nvidia drivers with PRIME render offload
dnf install -y xorg-x11-drv-nvidia akmod-nvidia
dnf install -y xorg-x11-drv-nvidia-cuda #CUDA support

# Enable Dynamic Power Management
cat > /etc/modprobe.d/nvidia.conf <<EOF
# Enable DynamicPwerManagement
# http://download.nvidia.com/XFree86/Linux-x86_64/435.17/README/dynamicpowermanagement.html
options nvidia NVreg_DynamicPowerManagement=0x02
EOF

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf 

#Copying PRIME render offload launcher
cp ../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

systemctl enable intel-undervolt

# Changing tlp config
sed -i "s/#CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_power/g" /etc/tlp.conf
sed -i "s/#SCHED_POWERSAVE_ON_AC=0/SCHED_POWERSAVE_ON_AC=1/g" /etc/tlp.conf

systemctl enable tlp

# Installing fido2luks
git clone https://github.com/shimunn/fido2luks.git && cd fido2luks
cargo install -f --path . --root /usr
cp dracut/96luks-2fa/fido2luks.conf /etc/
clear 
echo "Generating fido2luks credential, plug the correct FIDO2 device and press a button:"
read -n 1
echo "Press the FIDO2 button"
echo FIDO2LUKS_CREDENTIAL_ID=$(fido2luks credential) >> /etc/fido2luks.conf
set -a
. /etc/fido2luks.conf
fido2luks -i add-key /dev/disk/by-uuid/$(blkid -o value -s UUID /dev/nvme0n1p3)
cd dracut
make install
grubby --update-kernel=ALL --args="rd.luks.2fa=$FIDO2LUKS_CREDENTIAL_ID:$(blkid -o value -s UUID /dev/nvme0n1p3)"
mkdir /boot/fido2luks/
cp /usr/bin/fido2luks /boot/fido2luks/
cp /etc/fido2luks.conf /boot/fido2luks/

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install flathub com.discordapp.Discord io.lbry.lbry-app com.mojang.Minecraft com.google.AndroidStudio com.github.micahflee.torbrowser-launcher org.jdownloader.JDownloader org.gimp.GIMP com.tutanota.Tutanota com.obsproject.Studio com.getpostman.Postman io.dbeaver.DBeaverCommunity com.jetbrains.IntelliJ-IDEA-Community com.bitwarden.desktop -y

# Flatpak overrides
flatpak override --filesystem=~/.themes
flatpak override --filesystem=~/.fonts
flatpak override --filesystem=/usr/lib/jvm com.jetbrains.IntelliJ-IDEA-Community

# Add sysctl config
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing XAMPP
version="8.0.1"
curl -L "https://www.apachefriends.org/xampp-files/${version}/xampp-linux-x64-${version}-1-installer.run" > xampp.run
chmod +x xampp.run
./xampp.run --mode unattended --unattendedmodeui minimal

# Add intel_idle.max_cstate=1 to grub and update
grubby --update-kernel=ALL --args='intel_idle.max_cstate=1'
#grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

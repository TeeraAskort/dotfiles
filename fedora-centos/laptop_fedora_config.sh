#!/bin/bash

# Add intel_idle.max_cstate=1 to grub and update
grubby --update-kernel=ALL --args=intel_idle.max_cstate=0
grubby --update-kernel=ALL --args=processor.max_cstate=1

# Add fastestmirror to dnf configuration
echo "fastestmirror=1" | tee -a /etc/dnf/dnf.conf

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Install themes copr
dnf copr enable alderaeney/plata-theme-master -y

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
dnf install -y vim tilix telegram-desktop lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu pcsx2 plata-theme fontconfig-enhanced-defaults fontconfig-font-replacements intel-undervolt ffmpegthumbnailer zsh-autosuggestions chromium-freeworld google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts tlp nodejs npm code java-11-openjdk-devel aisleriot nextcloud-client nextcloud-client-nautilus thermald gnome-mahjongg plymouth-plugin-script

systemctl enable thermald

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
cp prime-run /usr/bin
chmod +x /usr/bin/prime-run

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

systemctl enable intel-undervolt

#TLP configuration
sed -i "s/#CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_power/g" /etc/tlp.conf
sed -i "s/#SCHED_POWERSAVE_ON_AC=0/SCHED_POWERSAVE_ON_AC=1/g" /etc/tlp.conf

systemctl enable tlp

# Changing plymouth theme
wget https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz
tar xzvf hexagon_2.tar.gz
sudo mv hexagon_2 /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R hexagon_2
rm hexagon_2.tar.gz

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install flathub com.discordapp.Discord

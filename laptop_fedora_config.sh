#!/bin/bash

# Add intel_idle.max_cstate=1 to grub and update
sed -ie 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 intel_idle.max_cstate=1"/' /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Add fastestmirror to dnf configuration
echo "fastestmirror=1" | tee -a /etc/dnf/dnf.conf

#Install RPMfusion
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Install themes copr
dnf copr enable mizuo/plata-theme -y

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
dnf install -y vim tilix telegram-desktop lutris steam mpv flatpak zsh zsh-syntax-highlighting papirus-icon-theme transmission-gtk wine winetricks gnome-tweaks dolphin-emu pcsx2 plata-theme fontconfig-enhanced-defaults fontconfig-font-replacements intel-undervolt ffmpegthumbnailer zsh-autosuggestions chromium-freeworld google-noto-cjk-fonts google-noto-emoji-color-fonts google-noto-emoji-fonts tlp nodejs npm code java-11-openjdk-devel aisleriot nextcloud-client nextcloud-client-nautilus thermald

systemctl enable thermald

dnf remove -y totem

#Update Appstream data
dnf groupupdate core -y

#Install multimedia codecs
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
dnf groupupdate sound-and-video -y

#Edit /etc/pulse/daemon.conf for improved audio
sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf
pulseaudio -k

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

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak applications
flatpak install flathub com.discordapp.Discord

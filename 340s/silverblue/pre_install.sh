#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$SUDO_USER

# Adding repos

## Openrazer repo
curl -L "https://download.opensuse.org/repositories/hardware:razer/Fedora_35/hardware:razer.repo" > /etc/yum.repos.d/hardware:razer.repo

## Docker repo
curl -L "https://copr.fedorainfracloud.org/coprs/hyperreal/better_fonts/repo/fedora-36/hyperreal-better_fonts-fedora-36.repo" > /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:hyperreal:better_fonts.repo

# Adding rpmfusion
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Setting up hostname
hostnamectl set-hostname link-340s

# First package installation
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks papirus-icon-theme java-11-openjdk-devel papirus-icon-theme java-11-openjdk-devel neovim python-neovim seahorse nodejs npm yarnpkg docker-ce docker-ce-cli containerd.io docker-compose brasero simple-scan lutris openrazer-meta pam-u2f pamu2fcfg libfido2

# Updating the system
rpm-ostree upgrade

# Installing mongo compass
rpm-ostree install "https://github.com/mongodb-js/compass/releases/download/v1.31.2/mongodb-compass-1.31.2.x86_64.rpm"

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Uninstalling flatpak applications
flatpak remove -y org.fedoraproject.MediaWriter org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Connections org.gnome.Contacts org.gnome.Evince org.gnome.Extensions org.gnome.Logs org.gnome.Maps org.gnome.NautilusPreviewer org.gnome.TextEditor org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer

# Installing flatpak applications
flatpak install flathub -y org.gtk.Gtk3theme.Adwaita-dark com.mojang.Minecraft org.jdownloader.JDownloader sh.ppy.osu net.pcsx2.PCSX2 com.valvesoftware.Steam com.getpostman.Postman com.visualstudio.code com.github.AmatCoder.mednaffe org.telegram.desktop com.discordapp.Discord org.strawberrymusicplayer.strawberry org.DolphinEmu.dolphin-emu io.mpv.Mpv io.github.sharkwouter.Minigalaxy xyz.z3ntu.razergenie org.gnome.Aisleriot org.gnome.Mahjongg org.desmume.DeSmuME com.obsproject.Studio org.gnome.Boxes org.nicotine_plus.Nicotine org.deluge_torrent.deluge com.nextcloud.desktopclient.nextcloud com.google.Chrome org.gimp.GIMP org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.Logs org.gnome.Maps org.gnome.NautilusPreviewer org.gnome.TextEditor org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.Geary org.gnome.FileRoller

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

# Adding ssh-askpass env var
echo "SSH_ASKPASS=/usr/libexec/seahorse/ssh-askpass" | tee -a /etc/environment

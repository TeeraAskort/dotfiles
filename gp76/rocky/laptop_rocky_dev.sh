#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Enabling RPMFusion
dnf install -y --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

# Enabling nvidia repo
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
dnf clean all

# Update OS
dnf upgrade -y

# Installing nvidia drivers and toolkits
dnf -y module install nvidia-driver:latest-dkms
dnf -y install cuda
dnf -y install tensorrt-libs tensorrt-devel

# Installing google chrome
wget https://dl.google.com/linux/linux_signing_key.pub
rpm --import linux_signing_key.pub
curl -L "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" > chrome.rpm
dnf localinstall -y ./chrome.rpm
rm ./chrome.rpm

# Installing python anaconda
dnf install libXi libXtst libXrandr libXcursor alsa-lib mesa-libEGL libXcomposite libXScrnSaver libXdamage mesa-libGL -y
curl -L "https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh" > conda.sh
bash conda.sh -b -p /opt/anaconda
rm -f conda.sh

# Installing VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
dnf install -y code

# Installing nodejs
curl -fsSL https://rpm.nodesource.com/setup_current.x | bash -

# Install R
yum config-manager --set-enabled powertools
yum install R -y

# Installing development tools
yum groupinstall -y 'Development Tools'

# Installing basic packages
dnf in -y papirus-icon-theme vim zsh flatpak thermald earlyoom zip gimp cryptsetup zram-generator libfido2 unrar alsa-lib-devel.x86_64 p7zip zstd nextcloud-client sqlite hunspell-ca hunspell-es-ES mythes-ca mythes-es mythes-en hyphen-es hyphen-ca hyphen-en lm_sensors java-17-openjdk-devel nodejs python39-pip

# Enabling services
systemctl enable thermald input-remapper

# Installing computer specific packages
dnf in -y pam-u2f pamu2fcfg

# Installing docker
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
user="$SUDO_USER"
usermod -aG docker $user

# Install virtualbox
dnf install wget curl gcc make perl bzip2 dkms kernel-devel kernel-headers  -y
dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
dnf install VirtualBox-7.0 -y

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install flathub -y com.getpostman.Postman com.jetbrains.PyCharm-Community org.gtk.Gtk3theme.Adwaita-dark com.valvesoftware.Steam net.lutris.Lutris org.telegram.desktop

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

# Copying prime-run
cp $directory/../dotfiles/prime-run /usr/bin

# Copying nvapi script
cp $directory/../dotfiles/nvapi /usr/bin

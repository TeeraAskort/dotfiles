#!/bin/bash

# Installing dnf
zypper install dnf libdnf-repo-config-zypp
dnf install PackageKit-backend-dnf
dnf swap PackageKit-backend-zypp PackageKit-backend-dnf

# Configuring dnf
echo "protect_running_kernel=False" | tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf
echo "fastestmirror=1" | tee -a /etc/dnf/dnf.conf

# Adding nvidia repo
dnf config-manager --add-repo https://download.nvidia.com/opensuse/tumbleweed 

# Refreshing repositories
zypper upgrade -y --refresh

# Install nvidia drivers
dnf in -y x11-video-nvidiaG06

# Enabling services
systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume

# Adding nvidia options
cat > /etc/modprobe.d/nvidia-power-management.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

echo "Nvidia drivers installed, reboot the computer"

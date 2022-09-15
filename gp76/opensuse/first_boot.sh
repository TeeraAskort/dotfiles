#!/bin/bash

# Adding nvidia repo
zypper addrepo https://download.nvidia.com/opensuse/tumbleweed NVIDIA

# Refreshing repositories
zypper --gpg-auto-import-keys refresh

# Install nvidia drivers
zypper in --auto-agree-with-licenses -y x11-video-nvidiaG06

# Enabling services
systemctl enable nvidia-suspend nvidia-hibernate

# Adding nvidia options
cat > /etc/modprobe.d/nvidia-power-management.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

echo "Nvidia drivers installed, reboot the computer"

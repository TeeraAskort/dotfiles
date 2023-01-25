#!/bin/bash

# Adding nvidia repo
zypper addrepo https://download.nvidia.com/opensuse/tumbleweed NVIDIA

# Refreshing repositories
zypper --gpg-auto-import-keys refresh

# Install nvidia drivers
zypper in --auto-agree-with-licenses -y x11-video-nvidiaG06

# Enabling services
systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume

# Adding nvidia options
cat > /etc/modprobe.d/nvidia-power-management.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

## Disabling sleep2idle
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 mem_sleep_default=deep"/' /etc/default/grub
update-bootloader --refresh

echo "Nvidia drivers installed, reboot the computer"

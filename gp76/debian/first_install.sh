#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Adding non-free repos
sed -i "s/non-free-firmware/non-free-firmware contrib non-free/g" /etc/apt/sources.list

# Adding 32bit support
dpkg --add-architecture i386
apt update

# Install headers
apt install -y linux-headers-amd64

# Install nvidia drivers
apt install -y nvidia-driver nvidia-driver-libs:i386 firmware-misc-nonfree nvidia-cuda-dev nvidia-cuda-toolkit libnvoptix1

# Updating grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1 modprobe.blacklist=nouveau mem_sleep_default=deep module_blacklist=i915 acpi_osi=! acpi_osi="Windows 2015" splash"/' /etc/default/grub
sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
update-grub

# Add preserve video memory
cat >/etc/modprobe.d/nvidia-power-management.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp 
EOF

# Initialize nvidia before xorg
cat >/etc/udev/rules.d/99-systemd-dri-devices.rules <<EOF
ACTION=="add", KERNEL=="card*", SUBSYSTEM=="drm", TAG+="systemd"
EOF

mkdir /etc/systemd/system/display-manager.service.d

cat >/etc/systemd/system/display-manager.service.d/10-wait-for-dri-devices.conf <<EOF
[Unit]
Wants=dev-dri-card0.device
After=dev-dri-card0.device
EOF

# Blacklist nvidiafb module
echo "blacklist nvidiafb" | tee /etc/modprobe.d/blacklist-nvidiafb.conf

cat >/etc/modprobe.d/blacklist.conf <<EOF
install i915 /usr/bin/false
install intel_agp /usr/bin/false
EOF

# Copying prime-run command
cp $directory/../dotfiles/prime-run /usr/bin

# Copying nvapi script
cp $directory/../dotfiles/nvapi /usr/bin

# Copying hitman-run script
cp $directory/../dotfiles/hitman-run /usr/bin

# Clear cache
apt clean

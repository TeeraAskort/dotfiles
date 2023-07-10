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

sed -i "s/#Experimental = false/Experimental = true/g" /etc/bluetooth/main.conf
sed -i "s/#KernelExperimental = false/KernelExperimental = true/g" /etc/bluetooth/main.conf

cat >/etc/modprobe.d/blacklist.conf <<EOF
install i915 /usr/bin/false
install intel_agp /usr/bin/false
install viafb /usr/bin/false
install radeon /usr/bin/false
install amdgpu /usr/bin/false
EOF

## Disabling sleep2idle
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 module_blacklist=i915 acpi_osi=! acpi_osi=\\"Windows 2015\\" mem_sleep_default=deep "/' /etc/default/grub
update-bootloader --refresh

echo "Nvidia drivers installed, reboot the computer"

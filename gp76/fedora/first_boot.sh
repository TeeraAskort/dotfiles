#!/bin/bash

echo "fastestmirror=1" | tee -a /etc/dnf/dnf.conf

# Update fedora
dnf up -y ; rpm --rebuilddb ; dnf up -y

# Install rpmfusion repos
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#Installing tainted repos
dnf in -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted

# Install plugins
dnf in -y dnf-plugins-core

# Install nvidia drivers
dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-vaapi-driver
cat > /etc/modprobe.d/nvidia.conf <<EOF
# Enable DynamicPwerManagement
# http://download.nvidia.com/XFree86/Linux-x86_64/440.31/README/dynamicpowermanagement.html
options nvidia NVreg_DynamicPowerManagement=0x02
EOF

cat > /lib/udev/rules.d/80-nvidia-pm.rules <<EOF
# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF

# Enable nvidia services
systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume

# Preserve video memory
cat > /etc/modprobe.d/nvidia-power-management.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
EOF
dracut -f

# Disable wayland
if [ -e "/usr/bin/gnome-session" ]; then 
	sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm/custom.conf
fi

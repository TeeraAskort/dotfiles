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

# Disable wayland
# if [ -e "/usr/bin/gnome-session" ]; then 
#	sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm/custom.conf
# fi

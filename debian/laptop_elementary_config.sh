#!/bin/bash

# Configuring grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_idle.max_cstate=1 "/' /etc/default/grub
update-grub

# Enable 32bit support
dpkg --add-architecture i386
apt update

# Add support for PPA
apt install software-properties-common

# Install elementary tweaks
add-apt-repository ppa:philip.scott/elementary-tweaks
apt update
apt install elementary-tweaks

# Install graphics ppa
add-apt-repository ppa:graphics-drivers/ppa
add-apt-repository ppa:kisak/kisak-mesa
apt update
apt full-upgrade
ubuntu-driver install

# Add vulkan support
apt install mesa-vulkan-drivers mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

# Enable appindicators
apt install indicator-application
sed -i "s/OnlyShowIn=Unity;GNOME;/OnlyShowIn=Unity;GNOME;Pantheon;/g" /etc/xdg/autostart/indicator-application.desktop
mv /etc/xdg/autostart/nm-applet.desktop /etc/xdg/autostart/nm-applet.old
wget "http://ppa.launchpad.net/elementary-os/stable/ubuntu/pool/main/w/wingpanel-indicator-ayatana/wingpanel-indicator-ayatana_2.0.3+r27+pkg17~ubuntu0.4.1.1_amd64.deb"
sudo dpkg -i wingpanel-indicator-ayatana_2.0.3+r27+pkg17~ubuntu0.4.1.1_amd64.deb

# Install lutris
add-apt-repository ppa:lutris-team/lutris
apt update
apt install lutris

# Install nextcloud-client
add-apt-repository ppa:nextcloud-devs/client
apt update
apt install nextcloud-client

# Install wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main"
apt install --install-recommends winehq-staging

# Install key-mapper
apt install git python3-setuptools
git clone https://github.com/sezanzeb/key-mapper.git
cd key-mapper && ./scripts/build.sh
sudo dpkg -i ./dist/key-mapper-*.deb
sudo apt -f install
cd .. && rm -r key-mapper

# Install required applications
apt install intel-microcode firefox telegram-desktop flatpak zsh zsh-syntax-highlighting fonts-noto-cjk openjdk-11-jdk mpv transmission-gtk vim git thermald earlyoom

# Copying prime-run launcher
cp ../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

# Copying Xorg config
cp ../dotfiles/xorg.conf /etc/X11

# Setting nvidia profile to intel
# prime-select intel

# Removing orphans
apt autoremove

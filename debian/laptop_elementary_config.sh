#!/bin/bash

# Configuring grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 intel_idle.max_cstate=1 nogpumanager"/' /etc/default/grub
update-grub2

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
ubuntu-drivers install

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

# Add wine repository
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main"

# Add faudio repository
wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key
apt-key add Release.key
add-apt-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'

# Install wine-staging
apt update
apt install --install-recommends winehq-staging

# Install key-mapper
apt install git python3-setuptools
git clone https://github.com/sezanzeb/key-mapper.git
cd key-mapper && ./scripts/build.sh
apt install ./dist/key-mapper-*.deb
cd .. && rm -r key-mapper

# Add papirus repo
add-apt-repository ppa:papirus/papirus

# Add mainline repo
add-apt-repository ppa:cappelikan/ppa

# Enable zsh-autosuggestions repo
echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-autosuggestions/xUbuntu_18.04/ /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-autosuggestions.list
curl -fsSL https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/xUbuntu_18.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg > /dev/null


# Install required applications
apt update
apt install intel-microcode firefox telegram-desktop flatpak zsh zsh-syntax-highlighting zsh-autosuggestions fonts-noto-cjk openjdk-11-jdk mpv transmission-gtk vim git thermald earlyoom papirus-icon-theme mainline rhythmbox

# Install discord and steam from the website
wget https://discord.com/api/download?platform=linux&format=deb
wget https://steamcdn-a.akamaihd.net/client/installer/steam.deb
sudo apt install ./discord*.deb ./steam*.deb

# Copying prime-run launcher
cp ../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

# Copying Xorg config
cp ../dotfiles/xorg.conf /etc/X11

# Setting nvidia profile to intel
# prime-select intel

# Removing orphans
apt autoremove

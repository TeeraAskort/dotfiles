#!/bin/bash

zypper in xf86-video-intel

# Installing Nvidia drivers
OneClickInstallCLI https://opensuse-community.org/nvidia_G05.ymp
OneClickInstallCLI https://software.opensuse.org/ymp/shells/openSUSE_Leap_15.2/fish.ymp
OneClickInstallCLI https://software.opensuse.org/ymp/editors/openSUSE_Leap_15.2/vim.ymp

# Enabling vscode repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo

# Installing repos
zypper ar -cfp 99 http://download.opensuse.org/repositories/games:/tools/openSUSE_Leap_15.2/ games
zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Leap_15.2/ wine
zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Leap_15.2/ emulators

zypper refresh

# Installing packages
zypper in chromium steam lutris papirus-icon-theme zsh tilix mpv rhythmbox dolphin-emu discord telegram-desktop flatpak retroarch code

# Adjusting sound quality
sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf

# Solving leap 15.2 flatpak issues
rm -r /var/lib/flatpak/repo

# Adding flathub repo 
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install flathub com.mojang.Minecraft com.katawa_shoujo.KatawaShoujo

# Installing prime offload launchers
cp prime* /usr/bin
chmod +x /usr/bin/prime*

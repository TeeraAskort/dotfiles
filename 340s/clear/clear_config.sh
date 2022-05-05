#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

# Updating the system
swupd update

# Installing basic packages
swupd bundle-add lutris games vim neovim mpv zsh java-basic earlyoom flatpak nodejs-basic kernel-native-dkms wine zip storage-utils unzip docker-compose yarn desktop-apps fonts-basic

# Installing flatpak applications
flatpak install flathub -y io.lbry.lbry-app org.jdownloader.JDownloader com.github.AmatCoder.mednaffe org.telegram.desktop com.getpostman.Postman net.pcsx2.PCSX2 org.desmume.DeSmuME org.strawberrymusicplayer.strawberry com.visualstudio.code com.discordapp.Discord com.mojang.Minecraft com.google.Chrome sh.ppy.osu com.nextcloud.desktopclient.nextcloud com.obsproject.Studio org.gimp.GIMP io.github.sharkwouter.Minigalaxy

# Adding hibernation config
cat > /etc/systemd/logind.conf <<EOF
[Login]
HandleLidSwitch=hibernate
HandleLidSwitchExternalPower=hibernate
IdleAction=hibernate
IdleActionSec=15min
EOF

cat > /etc/systemd/sleep.conf <<EOF
[Sleep]
AllowHibernation=yes
HibernateMode=shutdown
EOF



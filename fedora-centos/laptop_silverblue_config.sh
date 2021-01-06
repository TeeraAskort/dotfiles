#!/bin/bash

# Updating the system
rpm-ostree upgrade

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Removing flatpaks from fedora repo
flatpak remove org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit

# Installing flatpaks from flathub repo
flatpak install flathub org.telegram.desktop com.discordapp.Discord org.DolphinEmu.dolphin-emu org.eclipse.Java com.google.AndroidStudio com.nextcloud.desktopclient.nextcloud com.transmissionbt.Transmission org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit

# Adding rpmfusion repos
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Installing packages
rpm-ostree install zsh zsh-syntax-highlighting zsh-autosuggestions vim gnome-tweaks tilix intel-undervolt rhythmbox

# Adding intel_idle.max_cstate=1 kernel parameter
rpm-ostree kargs --append=intel_idle.max_cstate=1

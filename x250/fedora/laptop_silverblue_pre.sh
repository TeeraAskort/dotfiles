#!/usr/bin/env bash

## Installing flatpak apps from flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak uninstall org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit 

flatpak install flathub org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.Contacts org.gnome.Evince org.gnome.FileRoller org.gnome.Logs org.gnome.Maps org.gnome.Weather org.gnome.baobab org.gnome.clocks org.gnome.eog org.gnome.font-viewer org.gnome.gedit 

## Enable repositories
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

curl -L "https://copr.fedorainfracloud.org/coprs/dawid/better_fonts/repo/fedora-34/dawid-better_fonts-fedora-34.repo" > better_fonts.repo
cp better_fonts.repo /etc/yum.repos.d/

curl -L "https://copr.fedorainfracloud.org/coprs/alderaeney/mednaffe/repo/fedora-34/alderaeney-mednaffe-fedora-34.repo" > mednaffe.repo
cp mednaffe.repo /etc/yum.repos.d/

## Install packages


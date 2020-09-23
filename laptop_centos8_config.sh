#!/bin/bash
#Install EPEL
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --set-enabled PowerTools

#Install RPMfusion
yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm

#Install required packages
yum install steam vim mpv zsh flatpak gnome-tweaks

#Edit /etc/pulse/daemon.conf for improved audio
sudo sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /etc/pulse/daemon.conf
sudo sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /etc/pulse/daemon.conf
sudo sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /etc/pulse/daemon.conf
sudo sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /etc/pulse/daemon.conf
sudo sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /etc/pulse/daemon.conf
pulseaudio -k

#Install tilix
wget https://github.com/gnunn1/tilix/releases/latest/download/tilix.zip
unzip tilix.zip -d /
glib-compile-schemas /usr/share/glib-2.0/schemas/

#Compile emacs
wget http://ftp.rediris.es/mirror/GNU/emacs/emacs-26.3.tar.gz
tar xzvf emacs-26.3.tar.gz
cd emacs-26.3
yum install gtk3-devel libXpm-devel giflib-devel libjpeg-turbo-devel libtiff-devel gnutls-devel ncurses-devel
./configure
make
make install
cd ..
rm -r emacs-26.3

#Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install flatpak packages
flatpak install flathub org.telegram.desktop com.discordapp.Discord com.katawa_shoujo.KatawaShoujo com.meetfranz.Franz org.nextcloud.Nextcloud com.transmissionbt.Transmission

#Install materia theme
git clone --depth 1 https://github.com/nana-4/materia-theme
cd materia-theme
./install.sh

#Install papirus icon theme
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh | sh

#Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf 

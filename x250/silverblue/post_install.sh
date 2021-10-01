#!/usr/bin/env bash

user=$SUDO_USER

# Installing packages from rpmfusion
rpm-ostree install unrar ffmpeg ffmpegthumbnailer mozilla-openh264 gstreamer1-plugin-openh264 gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav gstreamer1-plugins-good-extras gstreamer1-plugins-bad-free-extras VirtualBox

# Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -75/g" /etc/intel-undervolt.conf

# Enabling services
systemctl enable intel-undervolt

# Adding user to vboxusers group
usermod -aG vboxusers $user

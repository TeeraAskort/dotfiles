#!/usr/bin/env bash

# Installing packages from rpmfusion
rpm-ostree install unrar p7zip ffmpeg ffmpegthumbnailer mozilla-openh264 gstreamer1-plugin-openh264 gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav gstreamer1-plugins-good-extras gstreamer1-plugins-bad-free-extras 

# Installing novideo drivers
rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia

# Adding novideo parameters
rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1

# Enabling services
systemctl enable docker

# Starting services
systemctl start docker

# Adding user to docker group
user="$SUDO_USER"
usermod -aG docker $user

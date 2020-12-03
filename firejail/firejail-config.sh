#!/bin/bash

# Enable apparmor
sudo apparmor_parser -r /etc/apparmor.d/firejail-default

# Enable firejail for all applications
sudo firecfg

# Enable drm to be playable on browsers
sudo sed -i "s/# browser-allow-drm no/browser-allow-drm yes/g" /etc/firejail/firejail.config

# Fix sound inside firejail
firecfg --fix-sound

# Fix .desktop applications
firecfg --fix

# Create config folder inside user .config folder
mkdir ~/.config/firejail

# Copy firejail configs
cp firefox.local ~/.config/firejail/

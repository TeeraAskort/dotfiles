#!/bin/bash

#Enabling i386 support
dpkg --add-architecture i386
apt update

# Installing needed packages for getting the third party repos
apt install curl wget apt-transport-https dirmngr 

# Adding third party repos
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/chrome.list
echo "deb [arch=i386,amd64] http://repo.steampowered.com/steam/ precise steam" | tee /etc/apt/sources.list.d/steam.list
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/code.list
echo "deb [arch=i386] https://dl.winehq.org/wine-builds/debian/ sid main" | tee /etc/apt/sources.list.d/wine.list

#Installing basic packages
apt install ffmpegthumbs mpv flatpak mednafen mednaffe vim papirus-icon-theme zsh zsh-syntax-highlighting zsh-autosuggestions firmware-linux steam nvidia-driver telegram-desktop nvidia-driver-libs:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386 libgl1:i386 mesa-vulkan-drivers:i386 mesa-vulkan-drivers neovim fonts-noto-cjk openjdk-8-jdk nextcloud-desktop thermald intel-microcode gamemode yakuake thunderbird hyphen-en-us mythes-en-us sqlitebrowser qbittorrent kpat kmahjongg palapeli net-tools tlp lp-rdw wget gnupg python3-dev cmake nodejs npm google-chrome-stable code

#Installing lutris
echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | apt-key add -
apt-get update
apt-get install lutris

# Installing outsider packages
curl -L "https://files.strawberrymusicplayer.org/strawberry_0.8.5-bullseye_amd64.deb" > strawberry.deb
apt install ./strawberry.deb 

#Installing flatpak applications
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.discordapp.Discord org.DolphinEmu.dolphin-emu com.github.micahflee.torbrowser-launcher io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio

#Copying prime render offload launcher
cp ../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

# Adding intel_idle.max_cstate=1 to grub
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 intel_idle.max_cstate=1"/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
update-grub2

# Setting hexagon_2 plymouth theme
curl -LO "https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz"
tar xzvf hexagon_2.tar.gz
cp -r hexagon_2 /usr/share/plymouth/themes
plymouth-set-default-theme -R hexagon_2

# Changing tlp config
sed -i "s/#CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_power/g" /etc/tlp.conf
sed -i "s/#SCHED_POWERSAVE_ON_AC=0/SCHED_POWERSAVE_ON_AC=1/g" /etc/tlp.conf

# Removing unused packages
apt autoremove

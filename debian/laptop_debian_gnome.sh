#!/bin/bash

#Enabling i386 support
dpkg --add-architecture i386
apt update

# Installing needed packages for getting the third party repos
apt install curl wget apt-transport-https dirmngr

# Adding third party repos 
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list
echo "deb [arch=i386,amd64] http://repo.steampowered.com/steam/ precise steam" | tee /etc/apt/sources.list.d/steam.list
echo "deb [arch=amd64,i386] http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/ /" | tee /etc/apt/sources.list.d/nextcloud-client.list

# Importing third party repos keys
wget -q -O - http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/Release.key | apt-key add -
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F24AEA9FB05498B7
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg

# Updating the system
apt update -y

# Upgrading the system
apt full-upgrade -y

#Installing basic packages
apt install -y ffmpegthumbnailer mpv flatpak mednafen mednaffe vim papirus-icon-theme zsh zsh-syntax-highlighting zsh-autosuggestions firmware-linux steam nvidia-driver telegram-desktop nvidia-driver-libs:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386 libgl1:i386 mesa-vulkan-drivers:i386 mesa-vulkan-drivers neovim fonts-noto-cjk openjdk-11-jdk nextcloud-desktop thermald intel-microcode gamemode tilix evolution hyphen-en-us mythes-en-us adwaita-qt sqlitebrowser net-tools tlp tlp-rdw wget apt-transport-https gnupg python3-dev cmake nodejs npm chromium code qt5-style-plugins gtk2-engines-murrine gtk2-engines-pixbuf libpam-u2f pamu2fcfg libfido2-1

# Removing unwanted packages
apt remove -y gnome-taquin tali gnome-tetravex four-in-a-row five-or-more lightsoff gnome-chess hoichess gnome-todo gnome-klotski hitori gnome-robots gnome-music gnome-nibbles gnome-mines quadrapassel swell-foop totem iagno gnome-sudoku rhythmbox

#Installing lutris
echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | apt-key add -
apt-get update
apt-get install -y lutris

#Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
echo "deb https://dl.winehq.org/wine-builds/debian/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list
apt update && apt install -y winehq-staging winetricks

# Installing outsider packages
version="0.8.5"
curl -L "https://files.strawberrymusicplayer.org/strawberry_${version}-bullseye_amd64.deb" > strawberry.deb
apt install -y ./strawberry.deb 

#Installing flatpak applications
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.discordapp.Discord org.DolphinEmu.dolphin-emu com.github.micahflee.torbrowser-launcher io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio com.bitwarden.desktop com.google.AndroidStudio com.jetbrains.IntelliJ-IDEA-Community

#Copying prime render offload launcher
cp ../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

# Adding intel_idle.max_cstate=1 to grub
sed -i "s/GRUB_CMDLINE_LINUX=\"\(.*\)\"/GRUB_CMDLINE_LINUX=\"\1 intel_idle.max_cstate=1 rd.luks.2fa=${FIDO2LUKS_CREDENTIAL_ID}:$(blkid -s UUID -o value /dev/nvme0n1p3)\"/" /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
update-grub

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

# Set qt theme to adwaita-dark
echo "QT_QPA_PLATFORMTHEME=gtk2" | tee -a /etc/environment

# Add sysctl config
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing XAMPP
version="8.0.2"
subver="0"
curl -L "https://www.apachefriends.org/xampp-files/${version}/xampp-linux-x64-${version}-${subver}-installer.run" > xampp.run
chmod +x xampp.run
./xampp.run --mode unattended --unattendedmodeui minimal


#!/bin/bash

#Enabling i386 support
sudo dpkg --add-architecture i386
sudo apt update

# Installing needed packages for getting the third party repos
sudo apt install curl wget apt-transport-https dirmngr

# Adding third party repos 
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
echo "deb [arch=i386,amd64] http://repo.steampowered.com/steam/ precise steam" | sudo tee /etc/apt/sources.list.d/steam.list
echo "deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | sudo tee /etc/apt/sources.list.d/faudio.list

# Importing third party repos keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F24AEA9FB05498B7
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
curl -LO "https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key" && sudo apt-key add Release.key

# Updating the system
sudo apt update -y

# Upgrading the system
sudo apt full-upgrade -y

# Installing basic packages
sudo apt install -y mpv flatpak mednafen mednaffe vim papirus-icon-theme zsh zsh-syntax-highlighting zsh-autosuggestions firmware-linux steam telegram-desktop neovim fonts-noto-cjk openjdk-11-jdk thermald intel-microcode gamemode hyphen-en-us mythes-en-us sqlitebrowser net-tools tlp wget apt-transport-https gnupg python3-dev cmake nodejs npm chromium code libpam-u2f pamu2fcfg libfido2-1 hunspell-es hunspell-en-us 

if [ "$XDG_CURRENT_DESKTOP" -eq "KDE" ]; then

	# Installing basic packages
	sudo apt install -y ffmpegthumbs yakuake thunderbird palapeli kpat kmahjongg 

	# Removing unwanted packages
	sudo apt remove --purge -y konqueror kaddressbook kmail akregator kopete k3b juk dragonplayer korganizer

	# Marking packages as installed manually
	sudo apt install -y libreoffice

elif [ "$XDG_CURRENT_DESKTOP" -eq "GNOME" ]; then

	# Installing basic packages
	sudo apt install -y ffmpegthumbnailer tilix evolution adwaita-qt 

	# Removing unwanted packages
	apt remove -y gnome-taquin tali gnome-tetravex four-in-a-row five-or-more lightsoff gnome-chess hoichess gnome-todo gnome-klotski hitori gnome-robots gnome-music gnome-nibbles gnome-mines quadrapassel swell-foop totem iagno gnome-sudoku rhythmbox

fi

#Installing lutris
echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y lutris

#Installing wine
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
echo "deb https://dl.winehq.org/wine-builds/debian/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list
sudo apt update && sudo apt install -y winehq-staging winetricks

# Installing outsider packages
version="0.8.5"
curl -L "https://files.strawberrymusicplayer.org/strawberry_${version}-bullseye_amd64.deb" > strawberry.deb
sudo apt install -y ./strawberry.deb 

#Installing flatpak applications
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.discordapp.Discord org.DolphinEmu.dolphin-emu com.github.micahflee.torbrowser-launcher io.lbry.lbry-app com.mojang.Minecraft com.tutanota.Tutanota com.obsproject.Studio com.bitwarden.desktop com.google.AndroidStudio com.jetbrains.IntelliJ-IDEA-Community

# Adding grub parameters
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 splash"/' /etc/default/grub
sudo sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
sudo update-grub

# Setting hexagon_2 plymouth theme
curl -LO "https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz"
tar xzvf hexagon_2.tar.gz
sudo cp -r hexagon_2 /usr/share/plymouth/themes
sudo plymouth-set-default-theme -R hexagon_2

# Removing unused packages
sudo apt autoremove --purge -y

# Add sysctl config
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.d/99-sysctl.conf

# Installing angular globally
sudo npm i -g @angular/cli
ng analytics off

# Installing XAMPP
version="8.0.2"
subver="0"
curl -L "https://www.apachefriends.org/xampp-files/${version}/xampp-linux-x64-${version}-${subver}-installer.run" > xampp.run
chmod +x xampp.run
sudo ./xampp.run --mode unattended --unattendedmodeui minimal


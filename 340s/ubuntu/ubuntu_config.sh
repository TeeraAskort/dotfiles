#!/usr/bin/env bash

if [ "$1" == "gnome" ]; then
    ## Adding 32 bit support
    dpkg --add-architecture i386
    apt update
    apt full-upgrade -y

    ## Changing repository
    sed -i "s/es.archive.ubuntu.com/ftp.udc.es/g" /etc/apt/sources.list

    ## Installing essential build tools and ppa
    apt-get install -y build-essential software-properties-common

    ## Installing drivers
    apt install -y libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386

    ## Installing wine
    apt install -y wine64 wine32 libasound2-plugins:i386 libsdl2-2.0-0:i386 libdbus-1-3:i386 libsqlite3-0:i386

    ## Installing lutris
    add-apt-repository ppa:lutris-team/lutris -y
    apt update
    apt install -y lutris

    ## Installing strawberry
    add-apt-repository ppa:jonaski/strawberry -y
    apt update
    apt install -y strawberry

    ## Installing mongo compass
    curl -L "https://github.com/mongodb-js/compass/releases/download/v1.31.2/mongodb-compass_1.31.2_amd64.deb" >compass.deb
    apt install -y ./compass.deb
    rm compass.deb

    ## Installing firefox correctly
    snap remove firefox
    add-apt-repository ppa:mozillateam/ppa -y
    cat >/etc/apt/preferences.d/mozillateamppa <<EOF
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501
EOF
    apt update
    apt install -t 'o=LP-PPA-mozillateam' -y firefox firefox-locale-es

    ## Installing docker
    apt-get install -y ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    ## Installing steam
    curl -LO "https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
    apt install -y ./steam.deb
    rm steam.deb

    ## Installing Google Chrome
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >>/etc/apt/sources.list.d/google-chrome.list
    apt update
    apt install -y google-chrome-stable

    ## Installing Nicotine+
    add-apt-repository ppa:nicotine-team/stable -y
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6CEB6050A30E5769
    apt update
    apt install -y nicotine

    ## Holding youtube-dl
    apt-mark hold youtube-dl

    ## Installing VSCode
    apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" >/etc/apt/sources.list.d/vscode.list
    rm -f packages.microsoft.gpg
    apt update
    apt install -y code

    ## Installing minecraft launcher
    curl -L "https://launcher.mojang.com/download/Minecraft.deb" >minecraft.deb
    apt install -y ./minecraft.deb
    rm minecraft.deb

    ## Installing openrazer drivers
    add-apt-repository ppa:openrazer/stable -y
    apt update
    apt install -y openrazer-meta

    ## Installing razergenie
    echo 'deb http://download.opensuse.org/repositories/hardware:/razer/xUbuntu_22.04/ /' | tee /etc/apt/sources.list.d/hardware:razer.list
    curl -fsSL https://download.opensuse.org/repositories/hardware:razer/xUbuntu_22.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/hardware_razer.gpg >/dev/null
    apt update
    apt install -y razergenie

    ## Installing multimedia codecs
    add-apt-repository multiverse -y
    apt-get install -y ubuntu-restricted-extras

    ## Pre accepting licenses
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
    echo ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula select false | debconf-set-selections

    ## Installing required packages
    apt install -y flatpak mpv mpv-mpris zsh zsh-autosuggestions zsh-syntax-highlighting fonts-noto-cjk fonts-noto-color-emoji thermald gamemode gparted vim neovim python3-neovim libfido2-1 mednafen mednaffe nextcloud-desktop pcsx2 zram-config minigalaxy yarnpkg gimp cups printer-driver-cups-pdf hplip libreoffice hunspell-en-us hunspell-es aspell-es mythes-en-us mythes-es hyphen-en-us hyphen-es zip unzip unrar p7zip lzop pigz pbzip2 bash-completion cryptsetup ntfs-3g neofetch papirus-icon-theme nodejs npm yt-dlp

    ## Installing computer specific applications
    apt install -y intel-microcode pamu2fcfg libpam-u2f

    ## Adding user to groups
    user=$SUDO_USER
    usermod -aG plugdev $user
    usermod -aG docker $user

    ## Adding hibernate options
    echo "AllowHibernation=yes" | tee -a /etc/systemd/sleep.conf
    echo "HibernateMode=shutdown" | tee -a /etc/systemd/sleep.conf

    ## Configuring flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    ## Installing flatpak applications
    flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark com.getpostman.Postman com.discordapp.Discord org.telegram.desktop org.jdownloader.JDownloader com.obsproject.Studio org.DolphinEmu.dolphin-emu

    ## Putting this option for the chrome-sandbox bullshit
    echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf
    echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

    ## Decrease swappiness
    echo "vm.swappiness = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
    echo "vm.vfs_cache_pressure = 50" | tee -a /etc/sysctl.d/99-sysctl.conf

    ## Virtual memory tuning
    echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
    echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

    # Optimize SSD and HDD performance
    cat >/etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

    ## Final desktop configs
    if [ "$1" == "gnome" ]; then
        ## Installing desktop specific packages
        apt install -y adwaita-qt gedit gvfs-backends aisleriot gnome-mahjongg ffmpegthumbnailer evolution deluge deluge-gtk evince simple-scan xdg-desktop-portal-gtk power-profiles-daemon brasero libopenraw7 libgsf-1-114 libgepub-0.6-0 gthumb file-roller gnome-boxes chrome-gnome-shell gnome-photos gnome-keyring gnome-calculator

        ## Removing desktop specific packages
        # apt remove -y

        ## Adding hibernate options
        echo "HandleLidSwitch=hibernate" | tee -a /etc/systemd/logind.conf
        echo "HandleLidSwitchExternalPower=hibernate" | tee -a /etc/systemd/logind.conf
        echo "IdleAction=hibernate" | tee -a /etc/systemd/logind.conf
        echo "IdleActionSec=15min" | tee -a /etc/systemd/logind.conf

        # Setting firefox env var
        echo "MOZ_ENABLE_WAYLAND=1" | tee -a /etc/environment

        # Adding gnome theming to qt
        echo "QT_STYLE_OVERRIDE=adwaita-dark" | tee -a /etc/environment
    fi

    ## Removing unused packages
    apt autoremove -y

else
    echo "ubuntu_config.sh [DESKTOP_CONFIG]"
    echo "gnome - To use the GNOME config"
fi

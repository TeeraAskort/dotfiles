#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep MZVLQ512HALU-000H1 | cut -d" " -f1)
dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_DT01ACA300 | cut -d" " -f1)

# Configuring locales
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=es_ES.UTF-8 >/etc/locale.conf
export LANG=es_ES.UTF-8

# Virtual console keymap
echo KEYMAP=es >/etc/vconsole.conf

# Change localtime
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

# Hostname
echo link-pc >/etc/hostname

# Restricting root login
sed -i "/pam_wheel.so use_uid/ s/^#//g" /etc/pam.d/su
sed -i "/pam_wheel.so use_uid/ s/^#//g" /etc/pam.d/su-l

# Create user
clear
useradd -m -g users -G wheel -s /bin/bash link
echo "Enter link's password"
until passwd link; do
	echo "Enter the password correctly"
done

# Sudo configuration
echo "%wheel ALL=(ALL) ALL" | tee -a /etc/sudoers.d/usewheel

# Enabling colors in pacman
sed -i "s/#Color/Color/g" /etc/pacman.conf
sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf

# Adding home OBS repo
cat >> /etc/pacman.conf <<EOF
[home_Alderaeney_Arch]
Server = https://ftp.gwdg.de/pub/opensuse/repositories/home:/Alderaeney/Arch/\$arch
EOF

# Adding home OBS repo key
key=$(curl -fsSL https://download.opensuse.org/repositories/home:Alderaeney/Arch/$(uname -m)/home_Alderaeney_Arch.key)
fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

pacman-key --init
pacman-key --add - <<< "${key}"
pacman-key --lsign-key "${fingerprint}"

pacman -Syu --noconfirm

# Updating keyring
pacman -Syu --noconfirm archlinux-keyring

# Enabling multilib repo
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu --noconfirm

# Installing xorg and xapps
pacman -S --noconfirm xorg-server xorg-apps

# Installing drivers
pacman -S --noconfirm mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader lib32-mesa xf86-input-wacom xf86-input-libinput libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau

# Installing services
pacman -S --noconfirm networkmanager openssh xdg-user-dirs haveged intel-ucode

# Enabling services
systemctl enable NetworkManager haveged

# Installing sound libraries
pacman -S --noconfirm alsa-utils alsa-plugins pipewire lib32-pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Enabling pipewire service
sudo -u link systemctl --user enable pipewire.socket
sudo -u link systemctl --user enable wireplumber.service

# Installing filesystem libraries
pacman -S --noconfirm dosfstools ntfs-3g btrfs-progs exfatprogs gptfdisk fuse2 fuse3 fuseiso sshfs cryptsetup f2fs-tools xfsprogs util-linux

# Enabling weekly trim
systemctl enable fstrim.timer

# Installing compresion tools
pacman -S --noconfirm zip unzip unrar p7zip lzop pigz pbzip2

# Installing generic tools
pacman -S --noconfirm vim nano pacman-contrib base-devel bash-completion usbutils lsof man net-tools inetutils vi

# Installing yay
newpass=$(tr </dev/urandom -dc "@#*%&_A-Z-a-z-0-9" | head -c16)
useradd -r -N -M -d /tmp/aurbuilder -s /usr/bin/nologin aurbuilder
echo -e "$newpass\n$newpass\n" | passwd aurbuilder
mkdir /tmp/aurbuilder
chmod 777 /tmp/aurbuilder
echo "aurbuilder ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/aurbuilder
echo "root ALL=(aurbuilder) NOPASSWD: ALL" >>/etc/sudoers.d/aurbuilder
cd /tmp/aurbuilder
sudo -u aurbuilder git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
sudo -u aurbuilder makepkg -si --noconfirm

# Optimizing aur
cores=$(nproc)
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z - --threads=0)/g" /etc/makepkg.conf
sed -i "s/COMPRESSZST=(zstd -c -z -q -)/COMPRESSZST=(zstd -c -z -q - --threads=0)/g" /etc/makepkg.conf
sed -i "/^COMPRESSGZ/ s/gzip/pigz/g" /etc/makepkg.conf
sed -i "/^COMPRESSBZ2/ s/bzip2/pbzip2/g" /etc/makepkg.conf
sed -i "/^CFLAGS/ s/-march=x86-64 -mtune=generic/-march=native/g" /etc/makepkg.conf
sed -i "/^CXXFLAGS/ s/-march=x86-64 -mtune=generic/-march=native/g" /etc/makepkg.conf
sed -i "s/#RUSTFLAGS=\"-C opt-level=2\"/RUSTFLAGS=\"-C opt-level=2 -C target-cpu=native\"/g" /etc/makepkg.conf

# Installing desktop environment
if [[ "$1" == "cinnamon" ]]; then
	pacman -S --noconfirm gedit cinnamon eog gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gnome-calculator gparted brasero gnome-sound-recorder file-roller tilix gnome-terminal gnome-system-monitor gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine geary transmission-gtk webp-pixbuf-loader libgepub libgsf libopenraw cinnamon-translations nemo-fileroller nemo-image-converter nemo-share blueberry system-config-printer gnome-screenshot gnome-disk-utility gnome-calendar home_Alderaeney_Arch/mint-themes evince kdeconnect zenity mpv

elif [[ "$1" == "gnome" ]]; then
	# Install GNOME
	pacman -S --noconfirm gnome gnome-tweaks gnome-nettool gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine evolution transmission-gtk webp-pixbuf-loader libgepub libgsf libopenraw brasero gnome-themes-extra xdg-desktop-portal xdg-desktop-portal-gtk gnome-software-packagekit-plugin celluloid

	# Removing unwanted packages
	pacman -Rns --noconfirm gnome-music epiphany totem orca gdm

elif [[ "$1" == "mate" ]]; then
	pacman -S --noconfirm mate mate-extra mate-media network-manager-applet mate-power-manager system-config-printer thunderbird virt-manager gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gparted brasero tilix gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine transmission-gtk webp-pixbuf-loader libgepub libgsf libopenraw blueberry home_Alderaeney_Arch/mint-themes mpv

elif [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]]; then
	pacman -S --noconfirm plasma ark dolphin dolphin-plugins gwenview ffmpegthumbs filelight kdeconnect sshfs kdialog kio-extras kio-gdrive kmahjongg palapeli kpat okular kcm-wacomtablet konsole spectacle kcalc kate kdegraphics-thumbnailers kcron ksystemlog kgpg kcharselect kdenetwork-filesharing audiocd-kio packagekit-qt5 gtk-engine-murrine kwallet-pam kwalletmanager kfind kwrite print-manager zeroconf-ioslave signon-kwallet-extension qbittorrent gnome-keyring plasma-wayland-session kdepim-addons akonadi kmail mpv qt5-imageformats webp-pixbuf-loader

	# Removing unwanted packages
	pacman -Rnsc --noconfirm oxygen

elif [[ "$1" == "xfce" ]]; then
	# Install xfce
	pacman -S --noconfirm xfce4 xfce4-goodies xcape pavucontrol network-manager-applet virt-manager thunderbird playerctl gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gnome-calculator gparted evince tilix gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine transmission-gtk webp-pixbuf-loader libgepub libgsf libopenraw blueberry system-config-printer xarchiver mpv

	# Remove unwanted applications
	pacman -Rns --noconfirm parole

fi

# Installing display-manager
if [[ "$1" == "gnome" ]]; then
	# Installing gdm-plymouth
	sudo -u aurbuilder yay -S --noconfirm --useask gdm-plymouth

	# Enabling gdm
	systemctl enable gdm

fi

if [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
	# Installing lightdm-slick-greeter
	pacman -S --noconfirm lightdm-slick-greeter

	# Installing lightdm-settings
	sudo -u aurbuilder yay -S --noconfirm lightdm-settings

	# Change lightdm theme
	sed -i "s/^#greeter-session=.*$/greeter-session=lightdm-slick-greeter/" /etc/lightdm/lightdm.conf

fi

if [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == cinnamon ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]]; then
	# Install plymotuh
	sudo -u aurbuilder yay -S --noconfirm plymouth

	# Enable lightdm or sddm
	if [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]]; then
		# Enable sddm
		systemctl enable sddm-plymouth
	else
		# Enable lightdm
		systemctl enable lightdm-plymouth
	fi
fi

# Setting default plymouth theme
plymouth-set-default-theme -R BGRT

# Copying arch logo for the plymouth theme
cp /usr/share/plymouth/arch-logo.png /usr/share/plymouth/themes/spinner/watermark.png

# Configuring mkinitcpio
pacman -S --noconfirm --needed lvm2
sed -i "s/udev autodetect modconf block filesystems/udev plymouth autodetect modconf block plymouth-encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
sed -i "s/MODULES=()/MODULES=(amdgpu)/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Install and configure systemd-boot
pacman -S --noconfirm --needed efibootmgr
bootctl install
mkdir -p /boot/loader/entries
cat >/boot/loader/loader.conf <<EOF
default  arch.conf
console-mode max
editor   no
EOF
cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/${rootDisk}p2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_idle.max_cstate=1 splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
cat >/boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux Fallback
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen-fallback.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/${rootDisk}p2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_idle.max_cstate=1 splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
bootctl update

# Installing printing services
pacman -S --noconfirm cups cups-pdf hplip ghostscript

# Enabling cups service
systemctl enable cups

# Installing office utilities
pacman -S --noconfirm libreoffice-fresh libreoffice-fresh-es hunspell-en_US hunspell-es_es mythes-en mythes-es hyphen-en hyphen-es

# Installing multimedia codecs
pacman -S --noconfirm gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav

# Installing gimp
pacman -S --noconfirm gimp gimp-help-es

# Installing required packages
pacman -S --noconfirm jdk11-openjdk dolphin-emu discord telegram-desktop flatpak wine-staging winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam thermald apparmor gamemode lib32-gamemode firefox firefox-i18n-es-es gparted noto-fonts gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-hack lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse firewalld obs-studio neovim nodejs npm python-pynvim libfido2 yad mednafen chromium nicotine+ yt-dlp pcsx2 zram-generator home_Alderaeney_Arch/strawberry-qt5 docker docker-compose rebuild-detector nextcloud-client 

# Enabling services
systemctl enable thermald apparmor firewalld systemd-oomd.service docker

# Configuring zram
cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram / 2

[zram1]
mount-point = /var/compressed
EOF

# Wine dependencies
pacman -S --needed --noconfirm wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader openssl-1.0

# Installing AUR packages
sudo -u aurbuilder yay -S --noconfirm dxvk-bin jdownloader2 visual-studio-code-bin pfetch minigalaxy minecraft-launcher razergenie openrazer-meta postman-bin

# Adding user to plugdev group
usermod -aG plugdev link

# Installing mpv-mpris
if [[ ! "$1" == "gnome" ]]; then
	sudo -u aurbuilder yay -S --noconfirm mpv-mpris
fi

# Installing desktop specific AUR packages
if [[ "$1" == "gnome" ]]; then
	sudo -u aurbuilder yay -S --noconfirm chrome-gnome-shell

elif [[ "$1" == "mate" ]]; then
	sudo -u aurbuilder yay -S --noconfirm mate-tweak mate-menu
fi

# Installing GTK styling
if [[ "$2" == "gtk" ]]; then
	sudo -u aurbuilder yay -S --noconfirm qgnomeplatform qgnomeplatform-qt6 adwaita-qt adwaita-qt6

	if [ "$1" == "gnome" ]; then
		# Setting environment variable
		echo "QT_STYLE_OVERRIDE=gnome" | tee -a /etc/environment
	else
		# Adding gnome theming to qt
		echo "QT_STYLE_OVERRIDE=adwaita-dark" | tee -a /etc/environment
	fi
fi

# Installing the rest of AUR packages with user link
sudo -u link yay -S --noconfirm protontricks mednaffe android-studio

# Linking yt-dlp to youtube-dl
ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl

# Removing aurbuilder
rm /etc/sudoers.d/aurbuilder
userdel aurbuilder
rm -r /tmp/aurbuilder

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Putting this option for the chrome-sandbox bullshit
echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf

# Adding hibernate options
echo "AllowHibernation=yes" | tee -a /etc/systemd/sleep.conf
echo "HibernateMode=shutdown" | tee -a /etc/systemd/sleep.conf

# Decrease swappiness
echo "vm.swappiness = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.vfs_cache_pressure = 50" | tee -a /etc/sysctl.d/99-sysctl.conf

# Virtual memory tuning
echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

# Optimize SSD and HDD performance
cat > /etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

# Cleaning orphans
pacman -Qtdq | pacman -Rns --noconfirm -

# Adding desktop specific final settings
if [[ "$1" == "xfce" ]]; then
	# Adding xprofile to user link
	sudo -u link echo "xcape -e 'Super_L=Control_L|Escape'" | tee -a /home/link/.xprofile

	# Setting cursor size in Xresources
	sudo -u link echo "Xcursor.size: 16" | tee -a /home/link/.Xresources

	# Adding gnome-keyring to pam
	echo "password optional pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

	# Add keyring unlock on login
	cp /etc/pam.d/login $directory/login
	awk 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' $directory/login $directory/login | tee $directory/login
	echo "session    optional     pam_gnome_keyring.so auto_start" | tee -a $directory/login
	mv $directory/login /etc/pam.d/login

	# Fixing xfce power manager
	sed -i "s/auth_admin/yes/g" /usr/share/polkit-1/actions/org.xfce.power.policy

elif [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]]; then
	# Adding GTK_USE_PORTAL=1 to /etc/environment
	echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

	# Configuring sddm
	echo "password optional pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

	# Add keyring unlock on login
	cp /etc/pam.d/login $directory/login
	awk 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' $directory/login $directory/login | tee $directory/login
	echo "session    optional     pam_gnome_keyring.so auto_start" | tee -a $directory/login
	mv $directory/login /etc/pam.d/login

fi

# Copying dotfiles folder to link
mv /dotfiles /home/link
chown -R link:users /home/link/dotfiles

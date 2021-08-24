#!/bin/bash

rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TS128GMTS430S | cut -d" " -f1)

dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_MQ01ABD100 | cut -d" " -f1)

# Configuring locales
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=es_ES.UTF-8 > /etc/locale.conf
export LANG=es_ES.UTF-8

# Virtual console keymap
echo KEYMAP=es > /etc/vconsole.conf

# Change localtime
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

# Hostname
echo link-x250 > /etc/hostname

# Root password
#clear
#echo "Enter root password"
#until passwd
#do
#	echo "Enter the password correctly"
#done

# Restricting root login
sed -i "/pam_wheel.so use_uid/ s/^#//g" /etc/pam.d/su
sed -i "/pam_wheel.so use_uid/ s/^#//g" /etc/pam.d/su-l

# Create user
clear
useradd -m -g users -G wheel -s /bin/bash link
echo "Enter link's password"
until passwd link
do
	echo "Enter the password correctly"
done

# Sudo configuration
EDITOR=vim visudo

# Enabling colors in pacman
sed -i "s/#Color/Color/g" /etc/pacman.conf
sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf

# Enabling multilib repo
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu --noconfirm

# Installing drivers 
pacman -S --noconfirm lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader libva-intel-driver intel-media-driver xf86-video-intel

# Installing services
pacman -S --noconfirm  networkmanager openssh xdg-user-dirs haveged intel-ucode bluez bluez-libs

# Enabling services
systemctl enable NetworkManager haveged bluetooth

# Installing sound libraries
pacman -S --noconfirm  alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pulseaudio-bluetooth

# Installing filesystem libraries
pacman -S --noconfirm  dosfstools ntfs-3g btrfs-progs exfatprogs gptfdisk fuse2 fuse3 fuseiso sshfs

# Installing compresion tools
pacman -S --noconfirm  zip unzip unrar p7zip lzop pigz pbzip2

# Installing generic tools
pacman -S --noconfirm  vim nano pacman-contrib base-devel bash-completion usbutils lsof man net-tools inetutils vi

# Installing paru
newpass=$(< /dev/urandom tr -dc "@#*%&_A-Z-a-z-0-9" | head -c16)
useradd -r -N -M -d /tmp/aurbuilder -s /usr/bin/nologin aurbuilder
echo -e "$newpass\n$newpass\n" | passwd aurbuilder
mkdir /tmp/aurbuilder
chmod 777 /tmp/aurbuilder
echo "aurbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aurbuilder
echo "root ALL=(aurbuilder) NOPASSWD: ALL" >> /etc/sudoers.d/aurbuilder
cd /tmp/aurbuilder
sudo -u aurbuilder git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
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

# Install cinnamon
pacman -S --noconfirm gedit cinnamon eog gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gnome-calculator gparted evince brasero gnome-sound-recorder file-roller tilix gnome-terminal gnome-system-monitor gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine geary transmission-gtk webp-pixbuf-loader libgepub libgsf libopenraw materia-gtk-theme gnome-boxes cinnamon-translations nemo-fileroller blueberry system-config-printer gnome-books gnome-screenshot gnome-disk-utility gnome-calendar

# Install lightdm-settings and slick-greeter
sudo -u aurbuilder paru -S --noconfirm lightdm-settings lightdm-slick-greeter

# Change lightdm theme
sed -i "s/^#greeter-session=.*$/greeter-session=lightdm-slick-greeter/" /etc/lightdm/lightdm.conf
 
# Installing plymouth theme
sudo -u aurbuilder paru -S --noconfirm plymouth-theme-hexagon-2-git plymouth

# Enabling lightdm
systemctl enable lightdm-plymouth

# Making lone theme default
plymouth-set-default-theme -R hexagon_2

# Configuring mkinitcpio
pacman -S --noconfirm --needed lvm2
sed -i "s/udev autodetect modconf block filesystems/udev plymouth autodetect modconf block plymouth-encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
sed -i "s/MODULES=()/MODULES=(i915)/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Install and configure systemd-boot
pacman -S --noconfirm --needed efibootmgr
bootctl install
mkdir -p /boot/loader/entries
cat > /boot/loader/loader.conf <<EOF
default  arch.conf
console-mode max
editor   no
EOF
cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux-hardened
initrd  /intel-ucode.img
initrd  /initramfs-linux-hardened.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/${rootDisk}2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_iommu=igfx_off splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
cat > /boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux Fallback
linux   /vmlinuz-linux-hardened
initrd  /intel-ucode.img
initrd  /initramfs-linux-hardened-fallback.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/${rootDisk}2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_iommu=igfx_off splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
bootctl update

# Installing printing services
pacman -S --noconfirm  cups cups-pdf hplip ghostscript

# Enabling cups service
systemctl enable cups

# Installing office utilities
pacman -S --noconfirm  libreoffice-fresh libreoffice-fresh-es hunspell-en_US hunspell-es_es mythes-en mythes-es hyphen-en hyphen-es

# Installing multimedia codecs
pacman -S --noconfirm  gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav

# Installing gimp
pacman -S --noconfirm  gimp gimp-help-es

# Installing required packages
pacman -S --noconfirm mpv jdk11-openjdk dolphin-emu discord telegram-desktop flatpak wine-staging winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam thermald earlyoom systembus-notify apparmor gamemode lib32-gamemode intel-undervolt firefox firefox-i18n-es-es gparted noto-fonts gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-hack lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse qemu libvirt firewalld obs-studio neovim nodejs npm python-pynvim libfido2 strawberry youtube-dl pam-u2f chromium 

# Enabling services
systemctl enable thermald earlyoom apparmor libvirtd firewalld 

# Wine dependencies
pacman -S --needed --noconfirm wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs 

# Installing AUR packages
cd /tmp/aurbuilder
rm -r *
for package in "dxvk-bin" "aic94xx-firmware" "wd719x-firmware" "mpv-mpris" "lbry-app-bin" "jdownloader2" "visual-studio-code-bin" "qt6gtk2" "pfetch"
do
	sudo -u aurbuilder git clone https://aur.archlinux.org/${package}.git
	cd $package && sudo -u aurbuilder makepkg -si --noconfirm
	cd ..
	rm -r $package
done

# Setting environment variable
echo "QT_QPA_PLATFORMTHEME=qt5gtk2" | tee -a /etc/environment

# Installing android studio
sudo -u link paru -S --noconfirm android-studio pamac-flatpak

# Removing aurbuilder
rm /etc/sudoers.d/aurbuilder
userdel aurbuilder
rm -r /tmp/aurbuilder

# Configuring intel-undervolt
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -75/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -75/g" /etc/intel-undervolt.conf
systemctl enable intel-undervolt

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Putting this option for the chrome-sandbox bullshit
echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Cleaning orphans
pacman -Qtdq | pacman -Rns --noconfirm -

# Copying dotfiles folder to link
mv /dotfiles /home/link
chown -R link:users /home/link/dotfiles

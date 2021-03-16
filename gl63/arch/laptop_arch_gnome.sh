#!/bin/bash

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
echo link-gl63-8rc > /etc/hostname

# Root password
#clear
#echo "Enter root password"
#until passwd
#do
#	echo "Enter the password correctly"
#done

# Restricting root login
passwd --lock root
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

# Enabling multilib repo
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu --noconfirm

# Installing drivers 
pacman -S --noconfirm  nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader nvidia-prime lib32-mesa vulkan-intel lib32-vulkan-intel xf86-input-wacom xf86-input-libinput

# Installing services
pacman -S --noconfirm  networkmanager openssh xdg-user-dirs haveged intel-ucode bluez bluez-libs

# Enabling services
systemctl enable NetworkManager haveged bluetooth

# Installing sound libraries
pacman -S --noconfirm  alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pulseaudio-bluetooth

# Installing filesystem libraries
pacman -S --noconfirm  dosfstools ntfs-3g btrfs-progs exfat-utils gptfdisk autofs fuse2 fuse3 fuseiso sshfs

# Installing compresion tools
pacman -S --noconfirm  zip unzip unrar p7zip lzop pigz pbzip2

# Installing generic tools
pacman -S --noconfirm  vim nano pacman-contrib base-devel bash-completion usbutils lsof man net-tools inetutils

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
sudo -u aurbuilder makepkg -si

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

# Install GNOME
pacman -S --noconfirm gnome gnome-tweaks gnome-nettool gnome-mahjongg aisleriot bubblewrap-suid gnome-software-packagekit-plugin ffmpegthumbnailer chrome-gnome-shell gtk-engine-murrine evolution tilix gnome-boxes transmission-gtk
 
# Removing unwanted packages
pacman -Rns --noconfirm gnome-music epiphany totem

# Installing plymouth
sudo -u aurbuilder paru -S gdm-plymouth plymouth-theme-hexagon-2-git

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
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/nvme0n1p2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_idle.max_cstate=1 i915.mitigations=off splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
cat > /boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux Fallback
linux   /vmlinuz-linux-zen
initrd  /intel-ucode.img
initrd  /initramfs-linux-zen-fallback.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/nvme0n1p2):luks:allow-discards root=/dev/lvm/root apparmor=1 lsm=lockdown,yama,apparmor intel_idle.max_cstate=1 i915.mitigations=off splash rd.udev.log_priority=3 vt.global_cursor_default=0 rw
EOF
bootctl update

# Enabling GDM
systemctl enable gdm

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
pacman -S --noconfirm mpv jdk11-openjdk dolphin-emu discord telegram-desktop flatpak wine-staging winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam thermald earlyoom systembus-notify apparmor gamemode lib32-gamemode intel-undervolt firefox firefox-i18n-es-es gparted noto-fonts font-bh-ttf gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-hack lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse qemu libvirt nextcloud-client firewalld obs-studio thunderbird thunderbird-i18n-es-es tlp inetutils net-tools neovim nodejs npm python-pynvim cmake intellij-idea-community-edition pam-u2f libfido2 mednafen networkmanager-l2tp strongswan mariadb dbeaver strawberry

# Enabling services
systemctl enable thermald tlp earlyoom apparmor libvirtd firewalld 

# Installing AUR packages
cd /tmp/aurbuilder
rm -r *
for package in "dxvk-bin" "aic94xx-firmware" "wd719x-firmware" "nerd-fonts-fantasque-sans-mono" "minecraft-launcher" "mpv-mpris" "lbry-app-bin" "tutanota-desktop-bin" "jdownloader2" "postman-bin" "bitwarden-bin"  "mednaffe" "slack-desktop" "anydesk-bin" "visual-studio-code-bin" "google-chrome" "qt5-styleplugins"
do
	sudo -u aurbuilder git clone https://aur.archlinux.org/${package}.git
	cd $package && sudo -u aurbuilder makepkg -si 
	cd ..
	rm -r $package
done

# Setting environment variables
echo "QT_QPA_PLATFORMTHEME='gtk2'" | tee -a /etc/environment

# Installing android studio
until sudo -u link paru -S android-studio
do
	echo "retrying"
done

# Installing angular globally
npm i -g @angular/cli
ng analytics off

# Installing ionic
npm i -g @ionic/cli

# Removing aurbuilder
rm /etc/sudoers.d/aurbuilder
userdel aurbuilder
rm -r /tmp/aurbuilder

# Configuring intel-undervolt
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf
systemctl enable intel-undervolt

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Putting this option for the chrome-sandbox bullshit
echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.d/99-sysctl.conf

# Cleaning orphans
pacman -Qtdq | pacman -Rns --noconfirm -

# Copying dotfiles folder to link
mv /dotfiles /home/link
chown -R link:users /home/link/dotfiles

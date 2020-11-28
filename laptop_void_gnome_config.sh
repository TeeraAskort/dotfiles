#!/bin/bash

# Installing parted
xbps-install -S -y parted
xbps-install -S -y parted

# Partition drives
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1M 512M
parted /dev/nvme0n1 -- set 1 boot on
parted /dev/nvme0n1 -- mkpart primary 512M 1024M
parted /dev/nvme0n1 -- mkpart primary 1024M 100%

# Encrypt drive
cryptsetup luksFormat --type luks1 /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 luks

# Create LVM volume
pvcreate /dev/mapper/luks
vgcreate lvm /dev/mapper/luks
lvcreate -L 16G -n swap lvm
lvcreate -L 70G -n root lvm
lvcreate -l 100%FREE -n home lvm

# Format drives
mkfs.xfs -L root -f /dev/lvm/root
mkfs.xfs -L home -f /dev/lvm/home
mkswap /dev/lvm/swap
swapon /dev/lvm/swap
mkfs.ext4 -t small /dev/nvme0n1p2
mkfs.vfat -F32 /dev/nvme0n1p1

# Mount drives
mount /dev/lvm/root /mnt

for dir in dev proc sys run; do mkdir -p /mnt/$dir ; mount --rbind /$dir /mnt/$dir ; mount --make-rslave /mnt/$dir ; done

mkdir /mnt/boot /mnt/home
mount /dev/lvm/home /mnt/home
mount /dev/nvme0n1p2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

# Install base system
xbps-install -Sy -R https://alpha.de.repo.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi lvm2

# Copy resolv.conf
cp /etc/resolv.conf /mnt/etc/resolv.conf

# Change root permissions
chroot /mnt chown root:root /
chroot /mnt chmod 755 /

# Change root password
clear
echo "Changing root password"
chroot /mnt passwd root

# Setting hostname
echo link-gl63-8rc > /mnt/etc/hostname

# Setting locale
echo "LANG=es_ES.UTF-8" > /mnt/etc/locale.conf
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /mnt/etc/default/libc-locales
sed -i "s/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/g" /mnt/etc/default/libc-locales
echo "KEYMAP=es" > /mnt/etc/vconsole.conf

# Reconfiguring locales
chroot /mnt xbps-reconfigure -f glibc-locales

# Setting up fstab
echo "/dev/lvm/root / xfs defaults 0 0" >> /mnt/etc/fstab
echo "/dev/lvm/home /home xfs defaults 0 0" >> /mnt/etc/fstab
echo "/dev/lvm/swap swap swap defaults 0 0" >> /mnt/etc/fstab
echo "/dev/nvme0n1p2 /boot ext4 defaults 0 0" >> /mnt/etc/fstab
echo "/dev/nvme0n1p1 /boot/efi vfat defaults 0 0" >> /mnt/etc/fstab

# Configuring grub
echo "GRUB_ENABLE_CRYPTODISK=y" >> /mnt/etc/fstab

variable=$(blkid -o value -s UUID /dev/nvme0n1p3)
sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 rd.lvm.vg=lvm rd.luks.uuid=$variable intel_idle.max_cstate=1 apparmor=1 security=apparmor\"/" /mnt/etc/default/grub

# Installing grub
chroot /mnt grub-install /dev/nvme0n1

# Generating initramfs
chroot /mnt xbps-reconfigure -fa

# Installing nonfree repos
chroot /mnt xbps-install -S -y void-repo-nonfree void-repo-multilib-nonfree void-repo-multilib

# Installing xorg
chroot /mnt xbps-install -S -y xorg

# Installing drivers
chroot /mnt xbps-install -S -y nvidia nvidia-libs-32bit mesa-vulkan-intel mesa-vulkan-intel-32bit xf86-video-intel xf86-input-wacom

# Installing basic utilities
chroot /mnt xbps-install -S -y unrar unzip zip p7zip lzop

# Installing filesystem libraries
chroot /mnt xbps-install -S -y dosfstools exfat-utils fuse-sshfs ntfs-3g btrfs-progs xfsprogs

# Installing services
chroot /mnt xbps-install -S -y dbus bluez cups cups-filters hplip NetworkManager elogind tlp thermald earlyoom cups-pdf

# Enabling services
chroot /mnt ln -s /etc/sv/dbus /etc/sv/NetworkManager /etc/sv/bluetoothd /etc/sv/cupsd /etc/sv/elogind /etc/sv/thermald /etc/sv/tlp /etc/sv/earlyoom /etc/runit/runsvdir/default

# Installing sound libraries
chroot /mnt xbps-install -S -y pulseaudio alsa-utils alsa-plugins-pulseaudio gst-plugins-bad1 gst-plugins-base1 gst-plugins-good1 gst-plugins-ugly1

# Installing generic utilities
chroot /mnt xbps-install -S -y vim nano bash-completion lsof man net-tools inetutils usbutils

# Installing GNOME
chroot /mnt xbps-install -S -y gnome evolution gnome-boxes gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-dictionary gnome-disk-utility gnome-documents gnome-font-viewer gnome-nettool gnome-photos gnome-screenshot gnome-system-monitor gnome-terminal simple-scan gdm aisleriot gnome-mahjongg transmission-gtk gtk-engine-murrine ffmpegthumbnailer

# Enabling gdm
chroot /mnt ln -s /etc/sv/gdm /etc/runit/runsvdir/default

# Disable wayland
sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /mnt/etc/gdm/custom.conf

# Installing office utilities
chroot /mnt xbps-install -S -y libreoffice libreoffice-i18n-es hunspell-es_ES hunspell-en_US

# Installing gimp
chroot /mnt xbps-install -S -y gimp

# Installing required packages
chroot /mnt xbps-install -S -y apparmor zsh zsh-autosuggestions zsh-syntax-highlighting emacs firefox firefox-i18n-es-ES tilix openjdk11 wine wine-mono wine-gecko winetricks protontricks intel-undervolt telegram-desktop noto-fonts-cjk noto-fonts-emoji chromium  papirus-icon-theme steam chromium-widevine intel-ucode lutris nextcloud-client plata-theme dolphin-emu font-hack-ttf nerd-fonts flatpak xdg-desktop-portal-gtk MultiMC git freshplayerplugin libpulseaudio-32bit gnutls-32bit libldap-32bit libgpg-error-32bit sqlite-32bit mpv rhythmbox

# Configure apparmor
sed -i "s/#APPARMOR=disable/APPARMOR=enforce/g" /mnt/etc/default/apparmor

# Configure intel-undervolt
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /mnt/etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /mnt/etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /mnt/etc/intel-undervolt.conf

# Configure pulseaudio
sed -i "s/; enable-lfe-remixing = no.*/enable-lfe-remixing = yes/" /mnt/etc/pulse/daemon.conf
sed -i "s/; lfe-crossover-freq = 0.*/lfe-crossover-freq = 20/" /mnt/etc/pulse/daemon.conf
sed -i "s/; default-sample-format = s16le.*/default-sample-format = s24le/" /mnt/etc/pulse/daemon.conf
sed -i "s/; default-sample-rate = 44100.*/default-sample-rate = 192000/" /mnt/etc/pulse/daemon.conf
sed -i "s/; alternate-sample-rate = 48000.*/alternate-sample-rate = 48000/" /mnt/etc/pulse/daemon.conf

# Create link user
clear
chroot /mnt useradd -m -g users -G wheel,audio,video,bluetooth -s /bin/bash link
echo "Enter link password"
chroot /mnt passwd link

# Edit sudoers
chroot /mnt visudo

# Install flatpak packages 
chroot /mnt flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
chroot /mnt flatpak install flathub com.discordapp.Discord

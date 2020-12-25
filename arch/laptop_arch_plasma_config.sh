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
clear
echo "Enter root password"
passwd

# Create user
clear
useradd -m -g users -G wheel -s /bin/bash link
echo "Enter link's password"
passwd link

# Sudo configuration
EDITOR=vim visudo

# Enabling colors in pacman
sed -i "s/#Color/Color/g" /etc/pacman.conf

# Enabling multilib repo
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu

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
pacman -S --noconfirm  zip unzip unrar p7zip lzop

# Installing generic tools
pacman -S --noconfirm  vim nano pacman-contrib base-devel bash-completion usbutils lsof man net-tools inetutils

# Installing yay
newpass=$(< /dev/urandom tr -dc "@#*%&_A-Z-a-z-0-9" | head -c16)
useradd -r -N -M -d /tmp/aurbuilder -s /usr/bin/nologin aurbuilder
echo -e "$newpass\n$newpass\n" | passwd aurbuilder
mkdir /tmp/aurbuilder
chmod 777 /tmp/aurbuilder
echo "aurbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aurbuilder
echo "root ALL=(aurbuilder) NOPASSWD: ALL" >> /etc/sudoers.d/aurbuilder
cd /tmp/aurbuilder
sudo -u aurbuilder git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
sudo -u aurbuilder makepkg -si

# Install Plasma
pacman -S --noconfirm plasma ark dolphin dolphin-plugins strawberry gwenview ffmpegthumbs filelight kdeconnect sshfs kdialog kio-extras kio-gdrive kmahjongg palapeli kpatience okular yakuake kcm-wacomtablet konsole spectacle kcalc kate kdegraphics-thumbnailers kcron ksystemlog kgpg kcharselect kdenetwork-filesharing kio-extras audiocd-kio packagekit-qt5 gtk-engine-murrine kwallet-pam kwalletmanager

# Installing plymouth
sudo -u aurbuilder yay -S plymouth

# Making the arch logo appear in the plymmouth
# cp /usr/share/plymouth/arch-logo.png /usr/share/plymouth/themes/spinner/watermark.png

# Installing lone plymouth theme
sudo -u aurbuilder yay -S plymouth-theme-hexagon-2-git

# Making lone theme default
plymouth-set-default-theme -R hexagon_2

# Configuring mkinitcpio
pacman -S --noconfirm --needed lvm2
sed -i "s/udev autodetect modconf block filesystems/udev plymouth autodetect modconf block plymouth-encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
sed -i "s/MODULES=()/MODULES=(i915)/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Add kernel paramenters
pacman -S --noconfirm --needed grub efibootmgr
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 cryptdevice=\/dev\/nvme0n1p2:luks:allow-discards root=\/dev\/lvm\/root intel_idle.max_cstate=1 apparmor=1 lsm=lockdown,yama,apparmor splash rd.udev.log_priority=3 vt.global_cursor_default=0"/' /etc/default/grub
sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Enabling SDDM
systemctl enable sddm-plymouth

# Removing unwanted Plasma apps
pacman -Rnc oxygen

# Adding environment variable to /etc/environment
echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

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
pacman -S --noconfirm mpv jdk11-openjdk dolphin-emu discord telegram-desktop flatpak code wine-staging winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam thermald tlp earlyoom systembus-notify apparmor gamemode lib32-gamemode intel-undervolt firefox firefox-i18n-es-es chromium pepper-flash flashplugin qbittorrent gparted noto-fonts font-bh-ttf gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-hack gnome-keyring lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse qemu libvirt virt-manager nextcloud-client firewalld 

# Enabling services
systemctl enable thermald tlp earlyoom apparmor libvirtd firewalld

# Install eclipse-jee with link's user
clear
echo "Installing eclipse-jee"
sudo -u link yay -S eclipse-jee

# Optimizing aur
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf

# Installing AUR packages
sudo -u aurbuilder yay -S dxvk-bin aic94xx-firmware wd719x-firmware nerd-fonts-fantasque-sans-mono minecraft-launcher android-studio xampp key-mapper-git mpv-mpris

# Enabling key-mapper
systemctl enable key-mapper

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

# Cleaning orphans
pacman -Qtdq | pacman -Rns -

# Copying dotfiles folder to link
mv /dotfiles /home/link
chown -R link:users /home/link/dotfiles

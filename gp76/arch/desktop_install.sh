#!/usr/bin/env bash

bootPart="3d781650-2935-4d52-b997-69c59f3ec36b"
efiPart="3E8F-38A6"

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep Micron_3400_MTFDKBA1T0TFH | cut -d" " -f1)

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
echo link-gp76 >/etc/hostname

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

# Adding Chaotic AUR repo
pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key FBA220DFC880C036
# pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' # 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Adding home OBS repo
cat >>/etc/pacman.conf <<EOF
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

# Downloading the chaotic-aur mirrorlist
curl -L "https://aur.chaotic.cx/mirrorlist.txt" > /etc/pacman.d/chaotic-mirrorlist
pacman -Sy --noconfirm chaotic-mirrorlist chaotic-keyring

pacman -Syu --noconfirm

# Updating keyring
pacman -Syu --noconfirm archlinux-keyring

# Enabling multilib repo
sed -i '/\[multilib\]/s/^#//g' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//g}' /etc/pacman.conf
pacman -Syu --noconfirm

# Installing linux kernel
pacman -S --noconfirm linux linux-headers

# Installing xorg and xapps
pacman -S --noconfirm xorg-server xorg-apps xorg-xrdb

# Installing drivers
pacman -S --noconfirm vulkan-icd-loader lib32-vulkan-icd-loader lib32-mesa vulkan-intel lib32-vulkan-intel xf86-input-wacom xf86-input-libinput libva-intel-driver intel-media-driver nvidia nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime switcheroo-control cuda cuda-tools cudnn

# Preserve video memory
cat > /etc/modprobe.d/nvidia-power-management.conf <<EOF
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
EOF
mkinitcpio -P

# Enabling services
systemctl enable switcheroo-control nvidia-suspend nvidia-hibernate nvidia-resume

# Initialize nvidia before xorg
cat > /etc/udev/rules.d/99-systemd-dri-devices.rules <<EOF
ACTION=="add", KERNEL=="card*", SUBSYSTEM=="drm", TAG+="systemd"
EOF

cat > /etc/systemd/system/display-manager.service.d/10-wait-for-dri-devices.conf <<EOF
[Unit]
Wants=dev-dri-card0.device
After=dev-dri-card0.device
EOF

# Installing services
pacman -S --noconfirm networkmanager openssh xdg-user-dirs haveged intel-ucode bluez bluez-libs

# Enabling services
systemctl enable NetworkManager haveged bluetooth

# Installing sound libraries
pacman -S --noconfirm alsa-utils alsa-plugins pipewire lib32-pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
# pacman -S --noconfirm alsa-utils alsa-plugins pulseaudio-alsa pulseaudio-jack pulseaudio-bluetooth

# Configuring pulseaudio
# sed -i "s/load-module module-suspend-on-idle/#load-module module-suspend-on-idle/g" /etc/pulse/default.pa

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
pacman -S --noconfirm yay

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
	pacman -S --noconfirm cinnamon eog gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gnome-calculator gparted brasero gnome-sound-recorder file-roller tilix gnome-terminal gnome-system-monitor gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine geary deluge deluge-gtk libappindicator-gtk3 libnotify webp-pixbuf-loader libgepub libgsf libopenraw cinnamon-translations nemo-fileroller nemo-image-converter nemo-share blueman system-config-printer gnome-screenshot gnome-disk-utility gnome-calendar mint-themes evince kdeconnect zenity gnome-boxes seahorse touchegg nemo-seahorse xdg-desktop-portal xdg-desktop-portal-gtk libsecret gvfs-google gnome-text-editor python-pyxdg strawberry 

	# Enabling services
	systemctl enable touchegg

elif [[ "$1" == "gnome" ]]; then
	# Install GNOME
	pacman -S --noconfirm extra/gnome gnome-tweaks gnome-nettool gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine geary deluge deluge-gtk libappindicator-gtk3 libnotify webp-pixbuf-loader libgepub libgsf libopenraw brasero gnome-themes-extra xdg-desktop-portal xdg-desktop-portal-gnome gnome-software-packagekit-plugin gdm-plymouth gnome-browser-connector simple-scan gnome-boxes seahorse libsecret gvfs-google python-nautilus gnome-text-editor python-pyxdg touchegg strawberry 
	
	# Enabling gdm
	systemctl enable gdm touchegg

	# Removing unwanted packages
	pacman -Rns --noconfirm gnome-music epiphany totem orca

elif [[ "$1" == "mate" ]]; then
	pacman -S --noconfirm mate mate-extra mate-media network-manager-applet mate-power-manager system-config-printer thunderbird gnome-boxes gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gparted brasero tilix gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine deluge deluge-gtk libappindicator-gtk3 libnotify webp-pixbuf-loader libgepub libgsf libopenraw blueman mint-themes mate-tweak mate-menu simple-scan libsecret strawberry 

elif [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]]; then
	pacman -S --noconfirm plasma sddm ark dolphin dolphin-plugins gwenview ffmpegthumbs filelight kdeconnect sshfs kdialog kio-extras kio-gdrive kmahjongg palapeli kpat okular kcm-wacomtablet konsole spectacle kcalc kate kdegraphics-thumbnailers kcron ksystemlog kgpg kcharselect kdenetwork-filesharing audiocd-kio packagekit-qt5 gtk-engine-murrine kwallet-pam kwalletmanager kfind print-manager signon-kwallet-extension qbittorrent plasma-wayland-session kdepim-addons akonadi kmail qt5-imageformats webp-pixbuf-loader ksshaskpass gnome-boxes xdg-desktop-portal-gtk xdg-desktop-portal-kde xdg-desktop-portal simple-scan gnome-keyring libsecret libgnome-keyring strawberry-qt5

	# Removing unwanted packages
	pacman -Rnsc --noconfirm oxygen

elif [[ "$1" == "xfce" ]]; then
	# Install xfce
	pacman -S --noconfirm xfce4 xfce4-goodies xcape pavucontrol network-manager-applet gnome-boxes thunderbird playerctl gvfs gvfs-google gvfs-mtp gvfs-nfs gvfs-smb lightdm gnome-calculator gparted evince tilix gnome-mahjongg aisleriot ffmpegthumbnailer gtk-engine-murrine deluge deluge-gtk libappindicator-gtk3 libnotify webp-pixbuf-loader libgepub libgsf libopenraw blueman system-config-printer xarchiver simple-scan mint-themes kdeconnect gnome-keyring libsecret libgnome-keyring strawberry 

	# Remove unwanted applications
	pacman -Rns --noconfirm parole

elif [[ "$1" == "el" ]]; then
	# Install enlightenment
	pacman -S --noconfirm enlightenment terminology ephoto evince network-manager-applet deluge deluge-gtk libappindicator-gtk3 libnotify lightdm ffmpegthumbnailer libgepub libopenraw libgsf webp-pixbuf-loader xarchiver gnome-calculator gparted thunderbird aisleriot gnome-mahjongg acpid xorg-xwayland packagekit geoip-database gnome-themes-extra gnome-boxes simple-scan gnome-keyring libsecret libgnome-keyring gnome-text-editor

	# Enabling services
	systemctl enable acpid

fi

if [[ "$1" == "cinnamon" ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "el" ]]; then
	# Installing lightdm-slick-greeter
	pacman -S --noconfirm lightdm-slick-greeter

	# Installing lightdm-settings
	pacman -S --noconfirm lightdm-settings

	# Change lightdm theme
	sed -i "s/^#greeter-session=.*$/greeter-session=lightdm-slick-greeter/" /etc/lightdm/lightdm.conf

fi

if [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]] || [[ "$1" == cinnamon ]] || [[ "$1" == "mate" ]] || [[ "$1" == "xfce" ]] || [[ "$1" == "el" ]]; then
	# Install plymotuh
	pacman -S --noconfirm plymouth

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
sed -i "s/udev autodetect modconf kms keyboard keymap consolefont block filesystems/udev plymouth autodetect modconf kms keyboard keymap consolefont block plymouth-encrypt lvm2 filesystems/g" /etc/mkinitcpio.conf
sed -i "s/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g" /etc/mkinitcpio.conf
mkinitcpio -P

# Install and configure systemd-boot
pacman -S --noconfirm --needed efibootmgr 

# mount /dev/nvme1n1p3 /mnt
# mount /dev/nvme1n1p2 /mnt/efi

# sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g" /etc/default/grub
# sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 cryptdevice=\/dev\/disk\/by-uuid\/$(blkid -s UUID -o value /dev/nvme0n1p3):luks:allow-discards root=\/dev\/lvm\/root resume=UUID=$(blkid -s UUID -o value /dev/lvm/swap) apparmor=1 lsm=lockdown,yama,apparmor splash rd.udev.log_priority=3 vt.global_cursor_default=0 kernel.yama.ptrace_scope=2 nvidia_drm.modeset=1 rcutree.rcu_idle_gp_delay=1 modprobe.blacklist=nouveau mem_sleep_default=deep modprobe.blacklist=nouveau \"/g" /etc/default/grub
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
# grub-mkconfig -o /boot/grub/grub.cfg

bootctl install
# efibootmgr --create --disk /dev/nvme0n1 --part 1 --loader "\EFI\systemd\systemd-bootx64.efi" --label "Linux Boot Manager"
mkdir -p /boot/loader/entries
cat >/boot/loader/loader.conf <<EOF
default  arch.conf
console-mode max
editor   no
EOF
cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/${rootDisk}p2):luks:allow-discards root=/dev/lvm/root resume=UUID=$(blkid -s UUID -o value /dev/lvm/swap) apparmor=1 lsm=lockdown,yama,apparmor splash rd.udev.log_priority=3 vt.global_cursor_default=0 kernel.yama.ptrace_scope=2 nvidia_drm.modeset=1 rcutree.rcu_idle_gp_delay=1 modprobe.blacklist=nouveau mem_sleep_default=deep modprobe.blacklist=nouveau ibt=off rw
EOF
cat >/boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux Fallback
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options cryptdevice=/dev/disk/by-uuid/$(blkid -s UUID -o value /dev/${rootDisk}p2):luks:allow-discards root=/dev/lvm/root resume=UUID=$(blkid -s UUID -o value /dev/lvm/swap) apparmor=1 lsm=lockdown,yama,apparmor splash rd.udev.log_priority=3 vt.global_cursor_default=0 kernel.yama.ptrace_scope=2 nvidia_drm.modeset=1 rcutree.rcu_idle_gp_delay=1 modprobe.blacklist=nouveau mem_sleep_default=deep modprobe.blacklist=nouveau ibt=off rw
EOF
bootctl update

# Installing printing services
pacman -S --noconfirm cups cups-pdf hplip ghostscript

# Enabling cups service
systemctl enable cups

# Installing office utilities
pacman -S --noconfirm libreoffice-fresh libreoffice-fresh-es hunspell-en_US hunspell-es_es mythes-en mythes-es hyphen-en hyphen-es aspell aspell-es aspell-en aspell-ca 

# Installing catalonian dictionary
sudo -u aurbuilder yay -S --noconfirm hunspell-ca mythes-ca hyphen-ca

# Installing multimedia codecs
pacman -S --noconfirm gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav

# Installing gimp
pacman -S --noconfirm gimp gimp-help-es

# Installing required packages
pacman -S --noconfirm jdk-openjdk dolphin-emu telegram-desktop flatpak wine-staging winetricks wine-gecko wine-mono lutris zsh zsh-autosuggestions zsh-syntax-highlighting noto-fonts-cjk papirus-icon-theme steam thermald apparmor gamemode lib32-gamemode gparted noto-fonts gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-hack lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse firewalld neovim nodejs npm python-pynvim libfido2 yad mednafen chromium nicotine+ yt-dlp zram-generator rebuild-detector nextcloud-client jdownloader2 visual-studio-code-bin pfetch-git heroic-games-launcher-bin mednaffe libva-vdpau-driver libvdpau-va-gl python-notify2 python-psutil osu-lazer android-tools piper solaar zpaq input-remapper-git openrazer-meta alsa-ucm-conf mpv mpv-mpris zstd obs-studio qt6-wayland firefox firefox-i18n-es-es docker docker-compose

# Enabling services
systemctl enable thermald apparmor firewalld systemd-oomd.service docker

Adding user to docker group
usermod -aG docker link

# Configuring zram
cat >/etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram / 2

[zram1]
mount-point = /var/compressed
EOF

# Installing computer specific packages
pacman -S --noconfirm pam-u2f tlp

# Enabling services
systemctl enable tlp

# Wine dependencies
pacman -S --noconfirm --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader

# Installing AUR packages
sudo -u aurbuilder yay -S --noconfirm dxvk-bin # touchegg

# Adding user to plugdev group
usermod -aG plugdev link

# Installing GTK styling
if [[ "$2" == "gtk" ]] || [[ "$1" == "el" ]]; then
	pacman -S --noconfirm adwaita-qt5 adwaita-qt6

	# Adding gnome theming to qt
	echo "QT_STYLE_OVERRIDE=adwaita-dark" | tee -a /etc/environment
fi

# Linking yt-dlp to youtube-dl
ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl

# Removing aurbuilder
rm /etc/sudoers.d/aurbuilder
userdel aurbuilder
rm -r /tmp/aurbuilder

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak applications
flatpak install -y flathub xyz.z3ntu.razergenie com.mongodb.Compass # com.obsproject.Studio

# Putting this option for the chrome-sandbox bullshit
echo "kernel.unprivileged_userns_clone=1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Decrease swappiness
echo "vm.swappiness = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.vfs_cache_pressure = 50" | tee -a /etc/sysctl.d/99-sysctl.conf

# Virtual memory tuning
echo "vm.dirty_ratio = 3" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "vm.dirty_background_ratio = 2" | tee -a /etc/sysctl.d/99-sysctl.conf

# Kernel hardening
echo "kernel.kptr_restrict = 1" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "net.core.bpf_jit_harden=2" | tee -a /etc/sysctl.d/99-sysctl.conf
echo "kernel.kexec_load_disabled = 1" | tee -a /etc/sysctl.d/99-sysctl.conf

# Create apparmor audit group
groupadd -r audit
usermod -aG audit link

sed -i "s/log_group = root/log_group = audit/g" /etc/audit/auditd.conf

# Optimize SSD and HDD performance
cat >/etc/udev/rules.d/60-sched.rules <<EOF
#set noop scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

# set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOF

# Auto enable bluetooth on startup
sed -i "s/#AutoEnable=false/AutoEnable=true/g" /etc/bluetooth/main.conf

# Adding nvidia pacman hook
mkdir -p /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/nvidia.hook <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P
EOF

cat > /etc/modprobe.d/blacklist.conf <<EOF
install i915 /usr/bin/false
install intel_agp /usr/bin/false
EOF

# Copying nvapi script
cp $directory/../dotfiles/nvapi /usr/bin

# Copying hitman-run script
cp $directory/../dotfiles/hitman-run /usr/bin

# Cleaning orphans
pacman -Qtdq | pacman -Rns --noconfirm -

# Adding desktop specific final settings
if [[ "$1" == "gnome" ]]; then
	# Disabling wayland
	sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm/custom.conf

	# Setting firefox env var
	echo "MOZ_ENABLE_WAYLAND=1" | tee -a /etc/environment

	# Disabling QT6 wayland backend
	# echo "QT_QPA_PLATFORM=xcb" | tee -a /etc/environment
	
	# Adding ssh-askpass env var
	echo "SSH_ASKPASS=/usr/lib/seahorse/ssh-askpass" | tee -a /etc/environment

	# Adding gnome-keyring to pam
	echo "password optional pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd
	
	ln -s /dev/null /etc/udev/rules.d/61-gdm.rules

	# Add keyring unlock on login
	awk 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' /etc/pam.d/login /etc/pam.d/login | tee $directory/tmp
	echo "session    optional     pam_gnome_keyring.so auto_start" | tee -a $directory/tmp
	mv $directory/tmp /etc/pam.d/login

elif [[ "$1" == "xfce" ]]; then
	# Adding xprofile to user link
	sudo -u link echo "xcape -e 'Super_L=Control_L|Escape'" | tee -a /home/link/.xprofile

	# Setting cursor size in Xresources
	sudo -u link echo "Xcursor.size: 16" | tee -a /home/link/.Xresources

	# Adding gnome-keyring to pam
	echo "password optional pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

	# Add keyring unlock on login
	awk 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' /etc/pam.d/login /etc/pam.d/login | tee $directory/tmp
	echo "session    optional     pam_gnome_keyring.so auto_start" | tee -a $directory/tmp
	mv $directory/tmp /etc/pam.d/login

	# Fixing xfce power manager
	sed -i "s/auth_admin/yes/g" /usr/share/polkit-1/actions/org.xfce.power.policy

elif [[ "$1" == "kde" ]] || [[ "$1" == "plasma" ]]; then
	# Adding GTK_USE_PORTAL=1 to /etc/environment
	echo "GTK_USE_PORTAL=1" | tee -a /etc/environment

	# Adding gnome-keyring to pam
	echo "password optional pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd

	# Add keyring unlock on login
	awk 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' /etc/pam.d/login /etc/pam.d/login | tee $directory/tmp
	echo "session    optional     pam_gnome_keyring.so auto_start" | tee -a $directory/tmp
	mv $directory/tmp /etc/pam.d/login

	# Copying ksshaskpass
	echo "SSH_ASKPASS=/usr/bin/ksshaskpass" | tee -a /etc/environment

	# Adding xrandr options to sddm
	echo "xrandr --dpi 96" | tee -a /usr/share/sddm/scripts/Xsetup

elif [[ "$1" == "cinnamon" ]]; then
	# Adding ssh-askpass env var
	echo "SSH_ASKPASS=/usr/lib/seahorse/ssh-askpass" | tee -a /etc/environment

	# Adding gnome-keyring to pam
	echo "password optional pam_gnome_keyring.so" | tee -a /etc/pam.d/passwd
	
	# Add keyring unlock on login
	awk 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' /etc/pam.d/login /etc/pam.d/login | tee $directory/tmp
	echo "session    optional     pam_gnome_keyring.so auto_start" | tee -a $directory/tmp
	mv $directory/tmp /etc/pam.d/login

fi

# Copying dotfiles folder to link
mv /dotfiles /home/link
chown -R link:users /home/link/dotfiles

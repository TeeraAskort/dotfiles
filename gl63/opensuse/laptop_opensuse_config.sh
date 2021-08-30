#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then

# Installing repos
zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/openSUSE_Tumbleweed/shells:zsh-users:zsh-completions.repo
zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators
zypper addrepo https://download.opensuse.org/repositories/hardware/openSUSE_Tumbleweed/hardware.repo
zypper addrepo -cfp 90 'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/' packman
zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
# zypper ar https://repo.vivaldi.com/archive/vivaldi-suse.repo

# Adding VSCode repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'

# Refreshing the repos
zypper --gpg-auto-import-keys refresh 

# Updating system
zypper dup -y

# Updating the system
zypper dist-upgrade --from packman --allow-vendor-change -y

# Installing wine-staging from wine repo
zypper in -y --from wine wine-staging wine-staging-32bit dxvk dxvk-32bit

# Installing codecs
zypper install -y --from packman ffmpeg gstreamer-plugins-{good,bad,ugly,libav} libavcodec-full

# Installing basic packages
zypper in -y chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions mpv mpv-mpris strawberry telegram-desktop flatpak gamemoded thermald plymouth-plugin-script nodejs npm intel-undervolt python39-neovim neovim noto-sans-cjk-fonts noto-coloremoji-fonts code earlyoom pam_u2f xf86-video-intel patterns-openSUSE-kvm_server patterns-server-kvm_tools qemu-audio-pa discord desmume zip dolphin-emu gimp flatpak-zsh-completion zsh-completions

# Enabling thermald service
systemctl enable thermald intel-undervolt earlyoom libvirtd

# Install nvidia drivers
zypper in --auto-agree-with-licenses -y x11-video-nvidiaG05

# Removing unwanted applications
zypper rm -y git-gui 

if [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
	# Installing DE specific applications
	zypper in -y yakuake qbittorrent kdeconnect-kde palapeli gnome-keyring pam_kwallet gnome-keyring-pam k3b kio_audiocd MozillaThunderbird

	# Removing unwanted DE specific applications
	zypper rm -y konversation kmines ksudoku kreversi
fi

# Changing plymouth theme
wget https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz
tar xzvf hexagon_2.tar.gz
mv hexagon_2 /usr/share/plymouth/themes/
plymouth-set-default-theme -R hexagon_2
rm hexagon_2.tar.gz

# Removing double encryption password asking
touch /.root.key
chmod 600 /.root.key
dd if=/dev/urandom of=/.root.key bs=1024 count=1
clear
echo "Enter disk encryption password"
until cryptsetup luksAddKey /dev/nvme0n1p2 /.root.key
do
	echo "Retrying"
done
sed -i "/WDC_WDS500G2B0C/ s/none/\/.root.key/g" /etc/crypttab
echo -e 'install_items+=" /.root.key "' | tee --append /etc/dracut.conf.d/99-root-key.conf >/dev/null
echo "/boot/ root:root 700" | tee -a /etc/permissions.local
chkstat --system --set
mkinitrd

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

# Adding flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install -y flathub io.lbry.lbry-app org.jdownloader.JDownloader com.google.AndroidStudio

# Flatpak overrides
flatpak override --filesystem=~/.fonts

# Add sysctl config
echo "dev.i915.perf_stream_paranoid=0" | tee -a /etc/sysctl.d/99-sysctl.conf

# Copying prime-run
cp $directory/../dotfiles/prime-run /usr/bin
chmod +x /usr/bin/prime-run

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
fi

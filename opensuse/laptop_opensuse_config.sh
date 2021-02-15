#!/bin/bash

# Installing repos
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Tumbleweed/ wine
sudo zypper ar -cfp 99 http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/openSUSE_Tumbleweed/ zsh-syntax-highlighting
sudo zypper addrepo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/openSUSE_Tumbleweed/shells:zsh-users:zsh-autosuggestions.repo
sudo zypper ar -cfp 99 https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/ emulators
sudo zypper addrepo https://download.opensuse.org/repositories/hardware/openSUSE_Tumbleweed/hardware.repo

# Adding VSCode repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'

# Refreshing the repos
sudo zypper refresh

# Updating the system
sudo zypper dup

# Installing nvidia drivers
sudo OneClickInstallCLI https://www.opensuse-community.org/nvidia_G05.ymp

# Installing codecs
if [ $XDG_CURRENT_DESKTOP = "KDE" ]; then

	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-kde.ymp

	# Installing packages
	sudo zypper in chromium steam lutris papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions yakuake mpv mpv-mpris strawberry dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel qbittorrent emacs kdeconnect-kde plymouth-plugin-script pam_u2f nodejs15 npm15 intel-undervolt gcc-c++ make python3 neovim python-neovim libnsl2 net-tools thunderbird noto-sans-cjk-fonts noto-coloremoji-fonts code

	# Remove unwanted packages
	sudo zypper rm git-gui akregator konversation kmines ksudoku kreversi 

else

	# Installing codecs
	sudo OneClickInstallCLI https://www.opensuse-community.org/codecs-gnome.ymp

	# Installing packages
	sudo zypper in chromium steam lutris plata-theme papirus-icon-theme vim zsh zsh-syntax-highlighting zsh-autosuggestions tilix mpv rhythmbox dolphin-emu telegram-desktop nextcloud-client flatpak gamemoded java-11-openjdk-devel fish thermald xf86-video-intel emacs plymouth-plugin-script pam_u2f nodejs15 npm15 intel-undervolt gcc-c++ make python3 neovim python-neovim libnsl2 net-tools noto-sans-cjk-fonts noto-coloremoji-fonts code

fi

# Enabling thermald service
sudo systemctl enable thermald

# Changing plymouth theme
wget https://github.com/adi1090x/files/raw/master/plymouth-themes/themes/pack_2/hexagon_2.tar.gz
tar xzvf hexagon_2.tar.gz
sudo mv hexagon_2 /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R hexagon_2
rm hexagon_2.tar.gz

# Removing double encryption password asking
sudo touch /.root.key
sudo chmod 600 /.root.key
sudo dd if=/dev/urandom of=/.root.key bs=1024 count=1
clear
echo "Enter disk encryption password"
sudo cryptsetup luksAddKey /dev/nvme0n1p2 /.root.key
sudo sed -i "/^cr_nvme/ s/none/\/.root.key/g" /etc/crypttab
echo -e 'install_items+=" /.root.key "' | sudo tee --append /etc/dracut.conf.d/99-root-key.conf > /dev/null
echo "/boot/ root:root 700" | sudo tee -a /etc/permissions.local
sudo chkstat --system --set
sudo mkinitrd

#Intel undervolt configuration
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

systemctl enable intel-undervolt

# Changing tlp config
sudo sed -i "s/#CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_power/g" /etc/tlp.conf
sudo sed -i "s/#SCHED_POWERSAVE_ON_AC=0/SCHED_POWERSAVE_ON_AC=1/g" /etc/tlp.conf

systemctl enable tlp

# Adding flathub repo 
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing flatpak apps
flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app com.mojang.Minecraft com.google.AndroidStudio com.github.micahflee.torbrowser-launcher org.jdownloader.JDownloader org.gimp.GIMP com.tutanota.Tutanota com.obsproject.Studio com.getpostman.Postman io.dbeaver.DBeaverCommunity com.jetbrains.IntelliJ-IDEA-Community com.bitwarden.desktop

# Flatpak overrides
sudo flatpak override --filesystem=~/.fonts

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

# Installing prime offload launchers
sudo cp ../dotfiles/prime-run /usr/bin
sudo chmod +x /usr/bin/prime-run

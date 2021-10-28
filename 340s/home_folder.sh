#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"


dataDiskUUID="8c5af7a6-3e34-4815-b7d3-31600c0c3c28"
dataDiskPartUUID="f5bfc5e5-583a-4605-9ac0-3e7981727239"

## Adjusting keymap
sudo localectl set-x11-keymap es

## Configuring data disk
sudo cryptsetup open /dev/disk/by-uuid/${dataDiskUUID} encrypteddata
mkdir $HOME/Datos
sudo mount /dev/mapper/encrypteddata $HOME/Datos
sudo cp /home/link/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=${dataDiskUUID} /root/.keyfile luks,discard" | sudo tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata /home/link/Datos btrfs defaults 0 0" | sudo tee -a /etc/fstab

## Removing home folders
rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

## Linking home folders
ln -s /home/link/Datos/Descargas $HOME
ln -s /home/link/Datos/Descargas $HOME/Downloads
ln -s /home/link/Datos/Documentos $HOME
ln -s /home/link/Datos/Escritorio $HOME
ln -s /home/link/Datos/Música $HOME
ln -s /home/link/Datos/Imágenes $HOME
ln -s /home/link/Datos/Torrent $HOME
ln -s /home/link/Datos/Nextcloud $HOME

## Overriding xdg-user-dirs
xdg-user-dirs-update --set DESKTOP $HOME/Datos/Escritorio
xdg-user-dirs-update --set DOCUMENTS $HOME/Datos/Documentos
xdg-user-dirs-update --set DOWNLOAD $HOME/Datos/Descargas
xdg-user-dirs-update --set MUSIC $HOME/Datos/Música
xdg-user-dirs-update --set PICTURES $HOME/Datos/Imágenes

## Installing vim plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Installing Ohmyzsh and powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

## Copying dotfiles
cp $directory/zsh/.zshrc ~
cp $directory/zsh/.general_alias ~
cp $directory/zsh/.arch_alias ~
cp $directory/zsh/.debian_alias ~
cp $directory/zsh/.fedora_alias ~
cp $directory/zsh/.silverblue_alias ~
cp $directory/zsh/.opensuse_alias ~
cp $directory/zsh/.elementary_alias ~
cp $directory/zsh/.solus_alias ~
cp $directory/zsh/.zorin_alias ~
mkdir -p ~/.config/pulse
cp $directory/dotfiles/daemon.conf ~/.config/pulse/
pulseaudio -k
pipewireS=$(systemctl --user list-unit-files --type service | grep pipewire.service | wc -l)
if [ $pipewireS -eq 1 ]; then 
	sudo cp -r $directory/../common/pipewire /etc
fi

# Copying .zshenv on debian
if [ $(lsb_release -is | grep "Debian" | wc -l) -eq 1 ]; then
	cp $directory/zsh/.zshenv ~
fi

## Configuring vim/neovim
cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q

## Copying chromium config
cp $directory/dotfiles/chromium-flags.conf ~/.config

## Configuring mpv
mkdir -p ~/.config/mpv
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Copy fonts
mkdir ~/.fonts
cd ~/.fonts
unzip ~/Documentos/fonts.zip
unzip ~/Documentos/fonts2.zip

# Installing NPM packages
if command -v rpm-ostree &> /dev/null; then
	npm config set prefix '~/.node_packages'
	npm install -g @angular/cli @vue/cli
else
	sudo npm install -g @angular/cli @vue/cli
fi

# Enabling opentabletdriver service
if command -v opentabletdriver &> /dev/null
then
	systemctl --user daemon-reload
	systemctl --user enable opentabletdriver --now
else
	sudo cp $directory/../common/99-opentabletdriver.rules /etc/udev/rules.d/99-opentabletdriver.rules
	sudo udevadm control --reload-rules
fi

# Configuring mariadb
if command -v mysql &> /dev/null ; then
	sudo mysql -u root -e "CREATE DATABASE farmcrash"
	sudo mysql -u root -e "CREATE USER 'farmcrash'@localhost IDENTIFIED BY 'farmcrash'"
	sudo mysql -u root -e "GRANT ALL PRIVILEGES ON farmcrash.* TO 'farmcrash'@localhost IDENTIFIED BY 'farmcrash'"
	sudo mysql -u root -e "CREATE USER projectes_andreuFurio@localhost IDENTIFIED BY 'projectes_andreuFurio'"
	sudo mysql -u root -e "CREATE DATABASE projectes_andreuFurio"
	sudo mysql -u root -e "GRANT ALL PRIVILEGES ON projectes_andreuFurio.* TO 'projectes_andreuFurio'@localhost IDENTIFIED BY 'projectes_andreuFurio'"
	sudo mysql projectes_andreuFurio -u root -e "CREATE TABLE alumnat (idalum integer auto_increment NOT NULL, nom VARCHAR(30) NOT NULL, cognoms VARCHAR(30) NOT NULL, email VARCHAR(50) NOT NULL, poblacio VARCHAR(30) NOT NULL, contrasenya VARCHAR(255) NOT NULL, rol ENUM('ROL_ALUMNAT', 'ROL_PROFESSORAT', 'ROL_ADMIN') NOT NULL, data TIMESTAMP NOT NULL, primary key(idalum))"
	sudo mysql projectes_andreuFurio -u root -e "CREATE TABLE curs(idcurs INTEGER auto_increment NOT NULL, curs VARCHAR(50) NOT NULL, primary key(idcurs))"
	sudo mysql projectes_andreuFurio -u root -e "CREATE TABLE projecte(idproj INTEGER auto_increment NOT NULL, titol VARCHAR(50) NOT NULL, cicle VARCHAR(50) NOT NULL, curs INTEGER NOT NULL, CONSTRAINT fk_projecte_curs FOREIGN KEY (curs) REFERENCES curs (idcurs) ON DELETE CASCADE ON UPDATE RESTRICT, descripcio MEDIUMTEXT NOT NULL, paraulesclau VARCHAR(255) NOT NULL, data TIMESTAMP NOT NULL, primary key(idproj))"
	sudo mysql projectes_andreuFurio -u root -e "CREATE TABLE relacioprojecte(idprof INTEGER NOT NULL, CONSTRAINT fk_relacio_professorat FOREIGN KEY (idprof) REFERENCES professorat (idprof) ON DELETE CASCADE ON UPDATE RESTRICT, idalum INTEGER NOT NULL, CONSTRAINT fk_relacio_alumnat FOREIGN KEY (idalum) REFERENCES alumnat (idalum) ON DELETE CASCADE ON UPDATE RESTRICT, idproj INTEGER NOT NULL, CONSTRAINT fk_relacio_projecte FOREIGN KEY (idproj) REFERENCES projecte (idproj) ON DELETE CASCADE ON UPDATE RESTRICT, idcurs INTEGER NOT NULL, CONSTRAINT fk_relacio_curs FOREIGN KEY (idcurs) REFERENCES curs (idcurs) ON DELETE CASCADE ON UPDATE RESTRICT, data TIMESTAMP NOT NULL)"
fi

## Configuring u2f cards
hostnm=$(hostname)

mkdir -p ~/.config/Yubico

echo "Insert FIDO2 card and press a key:"
read -n 1
pamu2fcfg -o pam://"$hostnm" -i pam://"$hostnm" > ~/.config/Yubico/u2f_keys
echo "Remove FIDO2 car and insert another, then press a key:"
read -n 1
pamu2fcfg -o pam://"$hostnm" -i pam://"$hostnm" -n >> ~/.config/Yubico/u2f_keys
sudo sed -i "2i auth            sufficient      pam_u2f.so origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/sudo
sudo sed -i "/auth.*substack.*system-auth/a auth\tsufficient\tpam_u2f.so cue origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/su
if [ -e /etc/pam.d/gdm-password ]; then
	sudo cp /etc/pam.d/gdm-password /etc/pam.d/gdm-password.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
	if diff /etc/pam.d/gdm-password.bak gdm-password ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
		sudo cp gdm-password /etc/pam.d/gdm-password
	else
		sudo cp gdm-password /etc/pam.d/gdm-password
	fi
	rm gdm-password
fi

if [ -e /etc/pam.d/xfce4-screensaver ]; then
	sudo cp /etc/pam.d/xfce4-screensaver /etc/pam.d/xfce4-screensaver.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/xfce4-screensaver /etc/pam.d/xfce4-screensaver > xfce4-screensaver
	if diff /etc/pam.d/xfce4-screensaver.bak xfce4-screensaver ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/xfce4-screensaver /etc/pam.d/xfce4-screensaver > xfce4-screensaver
		sudo cp xfce4-screensaver /etc/pam.d/xfce4-screensaver
	else
		sudo cp xfce4-screensaver /etc/pam.d/xfce4-screensaver
	fi
	rm xfce4-screensaver
fi

if [ -e /etc/pam.d/lightdm ]; then
	sudo cp /etc/pam.d/lightdm /etc/pam.d/lightdm.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/lightdm /etc/pam.d/lightdm > lightdm
	if diff /etc/pam.d/lightdm.bak lightdm ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/lightdm /etc/pam.d/lightdm > lightdm
		sudo cp lightdm /etc/pam.d/lightdm
	else
		sudo cp lightdm /etc/pam.d/lightdm
	fi
	rm lightdm
fi

if [ -e /etc/pam.d/sddm ]; then
	sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
	if diff /etc/pam.d/sddm.bak sddm ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
		sudo cp sddm /etc/pam.d/sddm
	else
		sudo cp sddm /etc/pam.d/sddm
	fi
	rm sddm
fi

if [ -e /etc/pam.d/kde ]; then
	sudo cp /etc/pam.d/kde /etc/pam.d/kde.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/kde /etc/pam.d/kde > kde
	if diff /etc/pam.d/kde.bak kde ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/kde /etc/pam.d/kde > kde
		sudo cp kde /etc/pam.d/kde
	else
		sudo cp kde /etc/pam.d/kde
	fi
	rm kde
fi

if [ -e /etc/pam.d/polkit-1 ]; then
	sudo cp /etc/pam.d/polkit-1 /etc/pam.d/polkit-1.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print\"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
	if diff /etc/pam.d/polkit-1.bak polkit-1 ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
		sudo cp polkit-1 /etc/pam.d/polkit-1
	else
		sudo cp polkit-1 /etc/pam.d/polkit-1
	fi
	rm polkit-1
fi

## Changing GNOME theme
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
	if [ -e /usr/share/themes/Materia-dark-compact ]; then
		gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark-compact"

	elif [ -e /usr/share/themes/Qogir-win-dark ]; then
		gsettings set org.gnome.desktop.interface gtk-theme "Qogir-win-dark"
	else
		if [ -e /usr/share/themes/Materia-dark ]; then 
			gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark"
		else
			gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
		fi
	fi
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat"
	gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
	gsettings set org.gnome.desktop.privacy disable-camera true
	gsettings set org.gnome.desktop.privacy disable-microphone true
	gsettings set org.gnome.desktop.privacy remember-recent-files false
	gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	gsettings set org.gnome.desktop.privacy remove-old-trash-files  true
	gsettings set org.gnome.desktop.privacy old-files-age 3
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
	gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
	gsettings set org.gnome.desktop.peripherals.trackball accel-profile 'flat'
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power power-button-action hibernate
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

# Changing zorin config
if [[ "$XDG_CURRENT_DESKTOP" == "zorin:GNOME" ]]; then
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat"
	gsettings set org.gnome.desktop.privacy disable-camera true
	gsettings set org.gnome.desktop.privacy disable-microphone true
	gsettings set org.gnome.desktop.privacy remember-recent-files false
	gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	gsettings set org.gnome.desktop.privacy remove-old-trash-files  true
	gsettings set org.gnome.desktop.privacy old-files-age 3
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
	gsettings set org.gnome.desktop.peripherals.trackball accel-profile 'flat'
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	gsettings set org.gnome.settings-daemon.plugins.power button-power hibernate
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action hibernate
	gsettings set org.gnome.settings-daemon.plugins.power lid-close-suspend-with-external-monitor true
	gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action hibernate
	gsettings set org.gnome.settings-daemon.plugins.power power-button-action hibernate
fi

## Changing Budgie config
if [[ "$XDG_CURRENT_DESKTOP" == "Budgie:GNOME" ]]; then
	if [ -e /usr/share/themes/Plata-Noir-Compact ]; then
		gsettings set org.gnome.desktop.interface gtk-theme "Plata-Noir-Compact"
	fi
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat"
	gsettings set org.gnome.desktop.privacy disable-camera true
	gsettings set org.gnome.desktop.privacy disable-microphone true
	gsettings set org.gnome.desktop.privacy remember-recent-files false
	gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	gsettings set org.gnome.desktop.privacy remove-old-trash-files true
	gsettings set org.gnome.desktop.privacy old-files-age 3
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
	gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
	gsettings set org.gnome.desktop.peripherals.trackball accel-profile 'flat'
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	gsettings set org.gnome.settings-daemon.plugins.power button-power hibernate
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action hibernate
	gsettings set org.gnome.settings-daemon.plugins.power lid-close-suspend-with-external-monitor true
	gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action hibernate
	gsettings set org.gnome.settings-daemon.plugins.power power-button-action hibernate
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

gsettings set org.gtk.Settings.FileChooser sort-directories-first true

# XFCE config
if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
	xfconf-query -c xfwm4 -p /general/vblank_mode -s glx
fi

## Adding user to audio group
user="$USER"
sudo usermod -aG audio $user

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@gmail.com"
git config --global init.defaultBranch master
git config --global credential.helper store

## Changing user shell
if ! command -v chsh &> /dev/null
then
	sudo lchsh link
else
	if [ -e /usr/bin/zsh ]; then 
		chsh -s /usr/bin/zsh
	else
		chsh -s /bin/zsh
	fi
fi
vim ~/.zshrc

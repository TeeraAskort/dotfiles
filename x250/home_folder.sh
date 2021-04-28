#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

rootDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TS128GMTS430S | cut -d" " -f1)

dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_MQ01ABD100 | cut -d" " -f1)

## Adjusting keymap
sudo localectl set-x11-keymap es

## Configuring data disk
sudo cryptsetup open /dev/${dataDisk}1 encrypteddata
mkdir /home/link/Datos
sudo mount /dev/mapper/encrypteddata /home/link/Datos
sudo cp /home/link/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=$(sudo blkid -s UUID -o value /dev/${dataDisk}1) /root/.keyfile luks,discard" | sudo tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata /home/link/Datos btrfs defaults 0 0" | sudo tee -a /etc/fstab

## Removing home folders
rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

## Linking home folders
ln -s /home/link/Datos/Descargas /home/link
ln -s /home/link/Datos/Descargas /home/link/Downloads
ln -s /home/link/Datos/Documentos /home/link
ln -s /home/link/Datos/Escritorio /home/link
ln -s /home/link/Datos/Música /home/link
ln -s /home/link/Datos/Imágenes /home/link
ln -s /home/link/Datos/Torrent /home/link
ln -s /home/link/Datos/Nextcloud /home/link

## Overriding xdg-user-dirs
xdg-user-dirs-update --set DESKTOP $HOME/Datos/Escritorio
xdg-user-dirs-update --set DOCUMENTS $HOME/Datos/Documentos
xdg-user-dirs-update --set DOWNLOAD $HOME/Datos/Descargas
xdg-user-dirs-update --set MUSIC $HOME/Datos/Música
xdg-user-dirs-update --set PICTURES $HOME/Datos/Imágenes

## Adding intel undervolt configuration
git clone https://github.com/kitsunyan/intel-undervolt.git

cd intel-undervolt && ./configure --enable-systemd && make && sudo make install
cd .. && sudo rm -r intel-undervolt

sudo sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -75/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -75/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -75/g" /etc/intel-undervolt.conf
sudo systemctl enable intel-undervolt

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
mkdir -p ~/.config/pulse
cp $directory/dotfiles/daemon.conf ~/.config/pulse/
pulseaudio -k

## Configuring vim/neovim
cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q
cd ~/.vim/plugged/youcompleteme 
python3 install.py --ts-completer 

## Copying chromium config
cp $directory/dotfiles/chromium-flags.conf ~/.config

## Configuring mpv
mkdir -p ~/.config/mpv/
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Copy fonts
mkdir ~/.fonts
cd ~/.fonts
unzip ~/Documentos/fonts.zip
unzip ~/Documentos/fonts2.zip

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
fi

if [ -e /etc/pam.d/polkit-1 ]; then
	sudo cp /etc/pam.d/polkit-1 /etc/pam.d/polkit-1.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
	if diff /etc/pam.d/polkit-1.bak polkit-1 ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
		sudo cp polkit-1 /etc/pam.d/polkit-1
	else
		sudo cp polkit-1 /etc/pam.d/polkit-1
	fi
fi

## Setting up gnome-keyring on sddm
if [ -e /etc/pam.d/sddm ]; then
	sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth      optional    pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
	if diff /etc/pam.d/sddm.bak sddm ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth      optional    pam_gnome_keyring.so\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
		sudo cp sddm /etc/pam.d/sddm
	else
		sudo cp sddm /etc/pam.d/sddm
	fi
fi

if [ -e /etc/pam.d/sddm ]; then
	sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
	awk "FNR==NR{ if (/session /) p=NR; next} 1; FNR==p{ print \"session   optional    pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
	if diff /etc/pam.d/sddm.bak sddm ; then
		awk "FNR==NR{ if (/session\t/) p=NR; next} 1; FNR==p{ print \"session   optional    pam_gnome_keyring.so auto_start\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
		sudo cp sddm /etc/pam.d/sddm
	else
		sudo cp sddm /etc/pam.d/sddm
	fi
fi

if [ -e /etc/pam.d/sddm ]; then
	sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
	awk "FNR==NR{ if (/password /) p=NR; next} 1; FNR==p{ print \"password       optional        pam_gnome_keyring.so use_authtok\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
	if diff /etc/pam.d/sddm.bak sddm ; then
		awk "FNR==NR{ if (/password\t/) p=NR; next} 1; FNR==p{ print \"password       optional        pam_gnome_keyring.so use_authtok\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
		sudo cp sddm /etc/pam.d/sddm
	else
		sudo cp sddm /etc/pam.d/sddm
	fi
fi

## making glx default vblank method on XFCE
if [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]; then
	xfconf-query -c xfwm4 -p /general/vblank_mode -s glx
	xfconf-query -c xfwm4 -p /general/raise_with_any_button -s false
	xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "FantasqueSansMono Nerd Font Mono 12"
	xfconf-query -c xfce4-screensaver -p /saver/fullscreen-inhibit -s true
	xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 30
	xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-battery -s 15
	xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -s 1
	xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -s 1	
	xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/critical-power-action -s 2
	xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/power-button-action -s 1
	xfconf-query -c thunar -p /last-location-bar -s "ThunarLocationButtons"
	xfconf-query -c keyboard-layout -p /Default/XkbLayout -s "es"
	
	if [ -e /usr/share/icons/Papirus-Dark ]; then
		xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
	fi

	if [ -e /usr/share/themes/Qogir-dark ]; then
		xfconf-query -c xfwm4 -p /general/theme -s "Qogir-dark"
		xfconf-query -c xsettings -p /Net/ThemeName -s "Qogir-dark"
	fi
fi

## Changing GNOME theme
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.gnome.desktop.interface font-name "Recursive Sans Linear Static Regular 11"
	gsettings set org.gnome.desktop.wm.preferences titlebar-font "Recursive Sans Linear Static Regular 11"
	gsettings set org.gnome.desktop.interface document-font-name "Recursive Sans Linear Static Regular 11"
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
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@alderaeney.com"
git config --global init.defaultBranch master

## Changing user shell
if ! command -v chsh &> /dev/null
then
	sudo lchsh link
else
	chsh -s /usr/bin/zsh
fi
vim ~/.zshrc

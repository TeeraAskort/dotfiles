#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$USER

## Adjusting keymap
sudo localectl set-x11-keymap es

sudo cryptsetup open /dev/sda1 encrypteddata
mkdir $HOME/Datos
sudo mount /dev/mapper/encrypteddata /home/link/Datos 
sudo cp $HOME/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=20976b67-c796-47c9-90dd-62c1edc34258 /root/.keyfile luks,discard" | sudo tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata $HOME/Datos ext4 defaults 0 0" | sudo tee -a /etc/fstab

rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

ln -s $HOME/Datos/Descargas $HOME
ln -s $HOME/Datos/Descargas $HOME/Downloads
ln -s $HOME/Datos/Documentos $HOME
ln -s $HOME/Datos/Escritorio $HOME
ln -s $HOME/Datos/Música $HOME
ln -s $HOME/Datos/Imágenes $HOME
ln -s $HOME/Datos/Torrent $HOME
ln -s $HOME/Datos/Nextcloud $HOME

xdg-user-dirs-update --set DESKTOP $HOME/Datos/Escritorio
xdg-user-dirs-update --set DOCUMENTS $HOME/Datos/Documentos
xdg-user-dirs-update --set DOWNLOAD $HOME/Datos/Descargas
xdg-user-dirs-update --set MUSIC $HOME/Datos/Música
xdg-user-dirs-update --set PICTURES $HOME/Datos/Imágenes

git clone https://github.com/kitsunyan/intel-undervolt.git
cd intel-undervolt && ./configure --enable-systemd && make && sudo make install
cd .. && sudo rm -r intel-undervolt

sudo sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf
sudo systemctl enable intel-undervolt

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
       
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

cp $directory/zsh/.zshrc ~
cp $directory/zsh/.general_alias ~
cp $directory/zsh/.arch_alias ~
cp $directory/zsh/.debian_alias ~
cp $directory/zsh/.fedora_alias ~
cp $directory/zsh/.silverblue_alias ~
cp $directory/zsh/.opensuse_alias ~
cp $directory/zsh/.elementary_alias ~
cp $directory/zsh/.solus_alias ~
mkdir -p ~/.config/pulse
cp $directory/dotfiles/daemon.conf ~/.config/pulse/
pulseaudio -k
cp -r $directory/../common/pipewire ~/.config
systemctl restart --user pipewire.service

## Configuring vim/neovim
cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q

## Copying chromium config
cp $directory/dotfiles/chromium-flags.conf ~/.config

## Configuring mpv
mkdir -p ~/.config/mpv/shaders/
curl -LO https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/ac09db2c0664150863e85d5a4f9f0106b6443a12/SSimDownscaler.glsl
curl -LO https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/424a8deae7d5a142d0bbbf1552a686a0421644ad/KrigBilateral.glsl
mv SSimDownscaler.glsl KrigBilateral.glsl ~/.config/mpv/shaders
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

mkdir ~/.fonts
cd ~/.fonts
unzip ~/Documentos/fonts.zip
unzip ~/Documentos/fonts2.zip

# Installing NPM packages
sudo npm install -g @angular/cli @vue/cli 

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
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
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
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

# XFCE config
if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
	xfconf-query -c xfwm4 -p /general/vblank_mode -s glx
fi

gsettings set org.gtk.Settings.FileChooser sort-directories-first true

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@alderaeney.com"
git config --global init.defaultBranch master
git config --global credential.helper store

## Adding user to audio group
sudo usermod -aG audio $user

## Changing user shell
if ! command -v chsh &> /dev/null
then
	sudo lchsh link
else
	chsh -s /usr/bin/zsh
fi
vim ~/.zshrc


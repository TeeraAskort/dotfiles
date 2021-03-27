#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

user=$USER

doas cryptsetup open /dev/sda1 encrypteddata
mkdir $HOME/Datos
doas mount /dev/mapper/encrypteddata /home/link/Datos 
doas cp $HOME/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=20976b67-c796-47c9-90dd-62c1edc34258 /root/.keyfile luks,discard" | doas tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata $HOME/Datos ext4 defaults 0 0" | doas tee -a /etc/fstab

rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

ln -s $HOME/Datos/Descargas $HOME
ln -s $HOME/Datos/Descargas $HOME/Downloads
ln -s $HOME/Datos/Documentos $HOME
ln -s $HOME/Datos/Escritorio $HOME
ln -s $HOME/Datos/Música $HOME
ln -s $HOME/Datos/Imágenes $HOME
ln -s $HOME/Datos/Torrent $HOME
ln -s $HOME/Datos/Nextcloud $HOME

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
       
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

cp $directory/zsh/.zshrc ~
cp $directory/zsh/.general_alias ~
cp $directory/zsh/.arch_alias ~
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
mkdir -p ~/.config/mpv/shaders/
curl -LO https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/ac09db2c0664150863e85d5a4f9f0106b6443a12/SSimDownscaler.glsl
curl -LO https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/424a8deae7d5a142d0bbbf1552a686a0421644ad/KrigBilateral.glsl
mv SSimDownscaler.glsl KrigBilateral.glsl ~/.config/mpv/shaders
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Configuring 2fa
hostnm=$(cat /etc/hostname)

mkdir ~/.fonts
cd ~/.fonts
unzip ~/Documentos/fonts.zip

## Configuring 2fa
hostnm=$(cat /etc/hostname)

mkdir -p ~/.config/Yubico

echo "Insert FIDO2 card and press a key:"
read -n 1
pamu2fcfg -o pam://"$hostnm" -i pam://"$hostnm" > ~/.config/Yubico/u2f_keys
echo "Remove FIDO2 car and insert another, then press a key:"
read -n 1
pamu2fcfg -o pam://"$hostnm" -i pam://"$hostnm" -n >> ~/.config/Yubico/u2f_keys
doas sed -i "2i auth            sufficient      pam_u2f.so origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/doas
doas sed -i "/auth.*substack.*system-auth/a auth\tsufficient\tpam_u2f.so cue origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/su
if [ -e /etc/pam.d/gdm-password ]; then
	doas cp /etc/pam.d/gdm-password /etc/pam.d/gdm-password.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
	if diff /etc/pam.d/gdm-password.bak gdm-password ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
		doas cp gdm-password /etc/pam.d/gdm-password
	else
		doas cp gdm-password /etc/pam.d/gdm-password
	fi
fi

if [ -e /etc/pam.d/sddm ]; then
	doas cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
	if diff /etc/pam.d/sddm.bak sddm ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
		doas cp sddm /etc/pam.d/sddm
	else
		doas cp sddm /etc/pam.d/sddm
	fi
fi

if [ -e /etc/pam.d/kde ]; then
	doas cp /etc/pam.d/kde /etc/pam.d/kde.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/kde /etc/pam.d/kde > kde
	if diff /etc/pam.d/kde.bak kde ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/kde /etc/pam.d/kde > kde
		doas cp kde /etc/pam.d/kde
	else
		doas cp kde /etc/pam.d/kde
	fi
fi

if [ -e /etc/pam.d/polkit-1 ]; then
	doas cp /etc/pam.d/polkit-1 /etc/pam.d/polkit-1.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
	if diff /etc/pam.d/polkit-1.bak polkit-1 ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            sufficient      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
		doas cp polkit-1 /etc/pam.d/polkit-1
	else
		doas cp polkit-1 /etc/pam.d/polkit-1
	fi
fi

## Changing GNOME theme
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@alderaeney.com"
git config --global init.defaultBranch master

## Adding user to audio group
doas usermod -aG audio $user

## Changing user shell
if ! command -v chsh &> /dev/null
then
	doas lchsh link
else
	chsh -s /usr/bin/zsh
fi
vim ~/.zshrc

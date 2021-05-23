#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep TOSHIBA_DT01ACA300 | cut -d" " -f1)

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

## Changing GNOME theme
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
	if [ -e /usr/share/themes/Materia-dark-compact ]; then
		gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark-compact"
	else
		gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
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
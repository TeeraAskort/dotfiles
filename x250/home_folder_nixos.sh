#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

## Configuring home folders
sudo rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

ln -s /home/link/Datos/Descargas /home/link
ln -s /home/link/Datos/Descargas /home/link/Downloads
ln -s /home/link/Datos/Documentos /home/link
ln -s /home/link/Datos/Escritorio /home/link
ln -s /home/link/Datos/Música /home/link
ln -s /home/link/Datos/Imágenes /home/link
ln -s /home/link/Datos/Torrent /home/link
ln -s /home/link/Datos/Nextcloud /home/link

## Downloading Plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Configuring vim/neovim
cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q
cd ~/.vim/plugged/youcompleteme 
python install.py 

## Copying fonts
mkdir ~/.fonts
cd ~/.fonts && unzip ~/Documentos/fonts.zip

## Configuring mpv
mkdir -p ~/.config/mpv/
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "sariaaskort@tuta.io"
git config --global init.defaultBranch master

## Installing flatpak applications
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.lbry.lbry-app com.tutanota.Tutanota com.github.micahflee.torbrowser-launcher org.jdownloader.JDownloader com.getpostman.Postman 

## Configuring u2f authentication
mkdir -p ~/.config/Yubico

echo "Insert FIDO2 card and press a key:"
read -n 1
until pamu2fcfg -o pam://"$(hostname)" -i pam://"$(hostname)" > ~/.config/Yubico/u2f_keys
do
	echo "Something went wrong reading the FIDO2 card"
done
echo "Remove FIDO2 card and insert another, then press a key:"
read -n 1
until pamu2fcfg -o pam://"$(hostname)" -i pam://"$(hostname)" -n >> ~/.config/Yubico/u2f_keys
do
	echo "Something went wrong reading the FIDO2 card"
done

## Add alias to zsh
echo "alias vim=\"nvim\"" | tee -a ~/.zshrc

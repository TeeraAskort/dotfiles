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

## Configuring mpv
mkdir -p ~/.config/mpv/
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@alderaeney.com"
git config --global init.defaultBranch master

## Installing flatpak applications
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.jdownloader.JDownloader 

## Configuring node packages
npm config set prefix '~/mutable_node_modules'
npm i -g @angular/cli @ionic/cli firebase-tools
echo "PATH=\"$PATH:$HOME/mutable_node_modules/bin\"" | tee -a ~/.zshrc

## Installing dictionaries
nix-env -iA nixos.hunspellDicts.es_ES nixos.hunspellDicts.en_US

## Add alias to zsh
echo "alias vim=\"nvim\"" | tee -a ~/.zshrc

#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

## Configuring home folders
sudo rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads 

ln -s /home/link/Datos/Descargas /home/link
ln -s /home/link/Datos/Descargas /home/link/Downloads
ln -s /home/link/Datos/Documentos /home/link
ln -s /home/link/Datos/Escritorio /home/link
ln -s /home/link/Datos/Música /home/link
ln -s /home/link/Datos/Imágenes /home/link
ln -s /home/link/Datos/Nextcloud /home/link
ln -s /home/link/Datos/Torrent /home/link

## Downloading Plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Copying chromium config
cp $directory/dotfiles/chromium-flags.conf ~/.config

## Configuring mpv
mkdir -p ~/.config/mpv/
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@alderaeney.com"
git config --global init.defaultBranch master
git config --global credential.helper store

## Installing flatpak applications
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.jdownloader.JDownloader io.gdevs.GDLauncher io.github.sharkwouter.Minigalaxy

## Configuring vim/neovim
cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q

## Installing dictionaries
nix-env -iA nixos.hunspellDicts.es_ES nixos.hunspellDicts.en_US

## Add alias to zsh
echo "alias vim=\"nvim\"" | tee -a ~/.zshrc

## Copying ssh key
mkdir ~/.ssh
cp ~/Documentos/id_ed25519* ~/.ssh
eval `ssh-agent -s`
until ssh-add ~/.ssh/id_ed25519; do
	echo "Bad password, retrying"
done

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

## Installing NPM packages
npm config set prefix '~/.node_packages'
npm install -g @angular/cli @vue/cli @ionic/cli

#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

sudo rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

ln -s /home/link/Datos/Descargas /home/link
ln -s /home/link/Datos/Descargas /home/link/Downloads
ln -s /home/link/Datos/Documentos /home/link
ln -s /home/link/Datos/Escritorio /home/link
ln -s /home/link/Datos/Música /home/link
ln -s /home/link/Datos/Imágenes /home/link
ln -s /home/link/Datos/Torrent /home/link
ln -s /home/link/Datos/Nextcloud /home/link

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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

mkdir -p ~/.config/mpv/shaders/
curl -LO https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/ac09db2c0664150863e85d5a4f9f0106b6443a12/SSimDownscaler.glsl
curl -LO https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/424a8deae7d5a142d0bbbf1552a686a0421644ad/KrigBilateral.glsl
mv SSimDownscaler.glsl KrigBilateral.glsl ~/.config/mpv/shaders
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

git config --global user.name "Alderaeney"
git config --global user.email "sariaaskort@tuta.io"
git config --global init.defaultBranch master

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.lbry.lbry-app com.tutanota.Tutanota com.github.micahflee.torbrowser-launcher org.jdownloader.JDownloader com.getpostman.Postman

mkdir -p ~/.config/Yubico

echo "Insert FIDO2 card and press a key:"
read -n 1
pamu2fcfg -o pam://"$(hostname)" -i pam://"$(hostname)" > ~/.config/Yubico/u2f_keys
echo "Remove FIDO2 card and insert another, then press a key:"
read -n 1
pamu2fcfg -o pam://"$(hostname)" -i pam://"$(hostname)" -n >> ~/.config/Yubico/u2f_keys

## Add alias to zsh
echo "alias vim=\"nvim\"" | tee -a ~/.zshrc

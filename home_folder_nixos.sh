#!/bin/bash

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

cp dotfiles/.vimrc ~

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

echo "source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" | tee -a ~/.zshrc

cp nixos/home.nix ~/.config/nixpkgs/home.nix

home-manager switch

mkdir -p ~/.config/mpv/shaders/
curl -LO https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/ac09db2c0664150863e85d5a4f9f0106b6443a12/SSimDownscaler.glsl
curl -LO https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/424a8deae7d5a142d0bbbf1552a686a0421644ad/KrigBilateral.glsl
mv SSimDownscaler.glsl KrigBilateral.glsl ~/.config/mpv/shaders
cp dotfiles/mpv.conf ~/.config/mpv/

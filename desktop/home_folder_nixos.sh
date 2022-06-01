#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

## Configuring home folders
sudo rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Sync

ln -s $HOME/Datos/Descargas $HOME
ln -s $HOME/Datos/Descargas $HOME/Downloads
ln -s $HOME/Datos/Documentos $HOME
ln -s $HOME/Datos/Escritorio $HOME
ln -s $HOME/Datos/Música $HOME
ln -s $HOME/Datos/Imágenes $HOME
ln -s $HOME/Datos/Nextcloud $HOME
ln -s $HOME/Datos/Sync $HOME

## Downloading Plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Copying chromium config
cp $directory/dotfiles/chromium-flags.conf ~/.config

## Configuring mpv
mkdir -p ~/.config/mpv/shaders/
curl -LO https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/ac09db2c0664150863e85d5a4f9f0106b6443a12/SSimDownscaler.glsl
curl -LO https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/424a8deae7d5a142d0bbbf1552a686a0421644ad/KrigBilateral.glsl
mv SSimDownscaler.glsl KrigBilateral.glsl ~/.config/mpv/shaders
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@gmail.com"
git config --global init.defaultBranch master
git config --global credential.helper store

## Changing GNOME theme
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
	gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
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
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type hibernate
	gsettings set org.gnome.settings-daemon.plugins.power power-button-action hibernate
	gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
fi

if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
	## Overriding xdg-user-dirs
	xdg-user-dirs-update --set DESKTOP $HOME/Escritorio
	xdg-user-dirs-update --set DOCUMENTS $HOME/Documentos
	xdg-user-dirs-update --set DOWNLOAD $HOME/Descargas
	xdg-user-dirs-update --set MUSIC $HOME/Música
	xdg-user-dirs-update --set PICTURES $HOME/Imágenes
fi

gsettings set org.gtk.Settings.FileChooser sort-directories-first true
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true

## Installing flatpak applications
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.jdownloader.JDownloader io.github.sharkwouter.Minigalaxy

## Configuring vim/neovim
cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q

## Installing dictionaries
nix-env -iA nixos.hunspellDicts.es_ES nixos.hunspellDicts.en_US

## Add alias to zsh
echo "source ~/.nix-alias" | tee -a ~/.zshrc
cp $directory/../zsh/.nix-alias ~

## Copying ssh key
mkdir ~/.ssh
cp ~/Documentos/id_ed25519* ~/.ssh
eval `ssh-agent -s`
until ssh-add ~/.ssh/id_ed25519; do
	echo "Bad password, retrying"
done

## Installing NPM packages
npm config set prefix '~/.node_packages'
npm install -g @ionic/cli

## Configuring docker
# cd $directory/../common
# sudo systemctl restart docker
docker pull mongo:latest

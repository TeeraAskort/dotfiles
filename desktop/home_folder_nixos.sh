#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

## Configuring home folders
sudo rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Sync

## Linking home folders
ln -s $HOME/Torrent/Descargas $HOME
ln -s $HOME/Torrent/Descargas $HOME/Downloads
ln -s $HOME/Torrent/Documentos $HOME
ln -s $HOME/Torrent/Escritorio $HOME
ln -s $HOME/Datos/Música $HOME
ln -s $HOME/Torrent/Imágenes $HOME
ln -s $HOME/Torrent/Nextcloud $HOME
ln -s $HOME/Torrent/Sync $HOME

## Downloading Plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Copying chromium config
cp $directory/dotfiles/chromium-flags.conf ~/.config

## Configuring Nextcloud
mkdir -p ~/.config/Nextcloud
cp ~/Documentos/nextcloud.cfg ~/.config/Nextcloud/nextcloud.cfg

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
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark
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
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
	gsettings set org.gnome.desktop.interface clock-show-date true
	gsettings set org.gnome.desktop.calendar show-weekdate true

	# Keybinds
	gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>w']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys play "['<Super>z']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys previous "['<Super>x']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys next "['<Super>c']"

	KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$KEY_PATH/custom0/']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Terminal"

	# Set nautilus as default file manager
	xdg-mime default org.gnome.Nautilus.desktop inode/directory application/x-gnome-saved-search

	if command -v kgx &> /dev/null ; then	
		gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "kgx"
	else
		gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "gnome-terminal"
	fi
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t'

	cp -r $directory/../common/gtk-4.0 ~/.config

	if command -v gedit &> /dev/null ; then
		gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	fi

	gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
fi

# Cinnamon config
if [[ "$XDG_CURRENT_DESKTOP" == "X-Cinnamon" ]]; then
	gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-suspend-with-external-monitor true
	gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-battery-action 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power button-power 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power button-suspend 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power critical-battery-action 'suspend'
	gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend true
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-ac 900
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery 300
	gsettings set org.cinnamon.settings-daemon.plugins.power idle-dim-battery true
	gsettings set org.cinnamon.settings-daemon.plugins.power idle-dim-time 90
	gsettings set org.cinnamon.settings-daemon.peripherals.keyboard numlock-state 'on'
	gsettings set org.cinnamon.desktop.privacy remember-recent-files false
	gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
	gsettings set org.cinnamon.theme name 'Mint-Y-Dark'
	gsettings set org.cinnamon.desktop.interface icon-theme 'Papirus-Dark'
	gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.cinnamon hotcorner-layout "['scale:true:150', 'scale:false:0', 'scale:false:0', 'desktop:false:0']"
	gsettings set org.cinnamon panels-height "['1:26']"
	gsettings set org.cinnamon.muffin tile-maximize true
	gsettings set org.cinnamon.muffin unredirect-fullscreen-windows true
	gsettings set org.cinnamon.desktop.interface clock-show-date true
	gsettings set org.nemo.icon-view default-zoom-level 'small'
	gsettings set org.nemo.preferences thumbnail-limit 8589934592
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark
	gsettings set org.cinnamon.desktop.wm.preferences resize-with-right-button true
	gsettings set org.cinnamon.desktop.peripherals.mouse accel-profile 'flat'
	gsettings set org.cinnamon.desktop.peripherals.touchpad tap-to-click true

	# Keybindings
	gsettings set org.cinnamon.desktop.keybindings.media-keys terminal "['<Primary><Alt>t', '<Super>t']"
	gsettings set org.cinnamon.desktop.keybindings.media-keys www "['XF86WWW', '<Super>w']"
	gsettings set org.cinnamon.desktop.keybindings.media-keys play "['XF86AudioPlay', '<Super>z']"
	gsettings set org.cinnamon.desktop.keybindings.media-keys next "['XF86AudioNext', '<Super>c']"
	gsettings set org.cinnamon.desktop.keybindings.media-keys previous "['XF86AudioPrev', '<Super>x']"
	gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "[]"
	gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', 'XF86ScreenSaver']"

	if [ -e ~/Imágenes/pape.jpg ]; then
		sudo cp ~/Imágenes/pape.jpg /usr/share/backgrounds
	fi

	echo "inode/directory=nemo.desktop" | tee -a ~/.config/mimeapps.list
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
flatpak install -y flathub org.jdownloader.JDownloader 

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
# npm install -g @ionic/cli

## Configuring docker
# cd $directory/../common
# sudo systemctl restart docker
# docker pull mongo:latest

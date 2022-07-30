#!/usr/bin/env bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

dataDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep DT01ACA300 | cut -d" " -f1)
torrentDisk=$(lsblk -io KNAME,TYPE,MODEL | grep disk | grep DT01ABA300 | cut -d" " -f1)

## Adjusting keymap
sudo localectl set-x11-keymap es

## Configuring data disk
echo "Enter data disk password: "
until sudo cryptsetup open /dev/${dataDisk}1 encrypteddata; do 
	echo "Bad password, retrying"
done
mkdir $HOME/Datos
sudo mount /dev/mapper/encrypteddata $HOME/Datos
sudo cp $HOME/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=$(sudo blkid -s UUID -o value /dev/${dataDisk}1) /root/.keyfile luks,discard" | sudo tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata $HOME/Datos btrfs defaults 0 0" | sudo tee -a /etc/fstab

## Removing home folders
rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent ~/Sync

## Linking home folders
ln -s $HOME/Datos/Descargas $HOME
ln -s $HOME/Datos/Descargas $HOME/Downloads
ln -s $HOME/Datos/Documentos $HOME
ln -s $HOME/Datos/Escritorio $HOME
ln -s $HOME/Datos/Música $HOME
ln -s $HOME/Datos/Imágenes $HOME
ln -s $HOME/Datos/Torrent $HOME
ln -s $HOME/Datos/Nextcloud $HOME
ln -s $HOME/Datos/Sync $HOME

## Overriding xdg-user-dirs
xdg-user-dirs-update --set DESKTOP $HOME/Datos/Escritorio
xdg-user-dirs-update --set DOCUMENTS $HOME/Datos/Documentos
xdg-user-dirs-update --set DOWNLOAD $HOME/Datos/Descargas
xdg-user-dirs-update --set MUSIC $HOME/Datos/Música
xdg-user-dirs-update --set PICTURES $HOME/Datos/Imágenes

## Installing vim plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## Installing Ohmyzsh and powerlevel10k
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

## Copying dotfiles
cp $directory/../zsh/.zshrc ~
cp $directory/../zsh/.general_alias ~
cp $directory/../zsh/.arch_alias ~
cp $directory/../zsh/.debian_alias ~
cp $directory/../zsh/.fedora_alias ~
cp $directory/../zsh/.silverblue_alias ~
cp $directory/../zsh/.opensuse_alias ~
cp $directory/../zsh/.elementary_alias ~
cp $directory/../zsh/.solus_alias ~
cp $directory/../zsh/.ubuntu_alias ~
if command -v pulseaudio &> /dev/null; then 
	mkdir -p ~/.config/pulse
	cp $directory/dotfiles/daemon.conf ~/.config/pulse/
	pulseaudio -k
fi

## Starting pipewire services
if command -v pipewire &> /dev/null ; then
	systemctl --user enable --now pipewire.socket
	systemctl --user enable --now pipewire-pulse.{service,socket}
	if command -v wireplumber &> /dev/null ; then
		systemctl --user enable --now wireplumber.service
	fi
fi

## Configuring pipewire
if command -v pipewire &> /dev/null ; then
	cd $directory/../common/
	cp -r pipewire ~/.config/
	systemctl --user restart pipewire.service pipewire-pulse.socket

	if command -v wireplumber &> /dev/null ; then
		cp -r wireplumber ~/.config
		systemctl --user restart wireplumber
	fi
fi

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

## Copy fonts
mkdir ~/.fonts
cd ~/.fonts
unzip ~/Documentos/fonts.zip
unzip ~/Documentos/fonts2.zip

# Installing NPM packages
if command -v rpm-ostree &> /dev/null; then
	npm config set prefix '~/.node_packages'
	npm install -g electron-installer-flatpak @vue/cli
	if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] && command -v lsb_release &> /dev/null && [[ $(lsb_release -is) != "openSUSE" ]]; then
		npm install -g bash-language-server
	fi
else
	sudo npm install -g electron-installer-flatpak @vue/cli
	if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] && command -v lsb_release &> /dev/null && [[ $(lsb_release -is) != "openSUSE" ]]; then
		sudo npm install -g bash-language-server
	fi
fi

# Enabling opentabletdriver service
if command -v opentabletdriver &> /dev/null
then
	systemctl --user daemon-reload
	systemctl --user enable opentabletdriver --now
else
	sudo cp $directory/../common/99-opentabletdriver.rules /etc/udev/rules.d/99-opentabletdriver.rules
	sudo udevadm control --reload-rules
fi

## Configuring flatpak steam
if [ $(flatpak list | grep Steam | wc -l) = 1 ]; then
	flatpak override --user --filesystem=$HOME/Datos com.valvesoftware.Steam	
fi

## Configuring flatpak minigalaxy
if [ $(flatpak list | grep Minigalaxy | wc -l) = 1 ]; then
	flatpak override --user --filesystem=$HOME/Datos/GOG\ Games io.github.sharkwouter.Minigalaxy
fi

## Configuring flatpak google chrome
if [ $(flatpak list | grep Chrome | wc -l) = 1 ]; then
	mkdir -p $HOME/.local/share/applications $HOME/.local/share/icons
	flatpak override --user --filesystem=$HOME/.local/share/applications com.google.Chrome
	flatpak override --user --filesystem=$HOME/.local/share/icons com.google.Chrome
fi

## Copying ssh key
mkdir ~/.ssh
cp ~/Documentos/id_ed25519* ~/.ssh
eval `ssh-agent -s`
until ssh-add ~/.ssh/id_ed25519; do
	echo "Bad password, retrying"
done

## Enabling firewall services
if command -v firewall-cmd &> /dev/null ; then
	sudo firewall-cmd --zone=public --permanent --add-service=kdeconnect
	sudo firewall-cmd --reload
fi

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

	cp -r $directory/../common/gtk-4.0 ~/.config

	if command -v gedit &> /dev/null ; then
		gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	fi

	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

# Changing zorin config
if [[ "$XDG_CURRENT_DESKTOP" == "zorin:GNOME" ]]; then
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat"
	gsettings set org.gnome.desktop.privacy disable-camera true
	gsettings set org.gnome.desktop.privacy disable-microphone true
	gsettings set org.gnome.desktop.privacy remember-recent-files false
	gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	gsettings set org.gnome.desktop.privacy remove-old-trash-files  true
	gsettings set org.gnome.desktop.privacy old-files-age 3
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
	gsettings set org.gnome.desktop.peripherals.trackball accel-profile 'flat'
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
fi

## Changing Budgie config
if [[ "$XDG_CURRENT_DESKTOP" == "Budgie:GNOME" ]]; then
	if [ -e /usr/share/themes/Plata-Noir-Compact ]; then
		gsettings set org.gnome.desktop.interface gtk-theme "Plata-Noir-Compact"
	fi
	gsettings set org.gnome.desktop.interface monospace-font-name "Rec Mono Semicasual Regular 11"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat"
	gsettings set org.gnome.desktop.privacy disable-camera true
	gsettings set org.gnome.desktop.privacy disable-microphone true
	gsettings set org.gnome.desktop.privacy remember-recent-files false
	gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	gsettings set org.gnome.desktop.privacy remove-old-trash-files true
	gsettings set org.gnome.desktop.privacy old-files-age 3
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
	gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900
	gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'
	gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
	gsettings set org.gnome.desktop.peripherals.trackball accel-profile 'flat'
	gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	if [ -e /usr/share/icons/Papirus-Dark/ ]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

# XFCE config
if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
	xfconf-query -c xfwm4 -p /general/vblank_mode -s glx

	if [ -e ~/Imágenes/pape.jpg ]; then
		sudo cp ~/Imágenes/pape.jpg /usr/share/backgrounds
	fi

fi

gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gsettings set org.gtk.Settings.FileChooser sort-directories-first true

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

if [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then
	sudo cp ~/Imágenes/pape.jpg /usr/share/wallpapers/

	if command -v flatpak &> /dev/null; then
		flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
	fi
fi

if [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
	cp $directory/../common/applications/* ~/.e/e/applications/startup
	cp /etc/xdg/autostart/gnome-keyring* ~/.e/e/applications/startup
	cat > ~/.pam_environment <<EOF
#Set gnome-keyring as the ssh authentication agent
SSH_AUTH_SOCK=/run/user/${UID}/keyring/ssh
EOF

	sudo mkdir /usr/share/backgrounds
	sudo cp ~/Imágenes/jowens_kauai.jpg /usr/share/backgrounds/

	gsettings set org.gnome.gedit.preferences.editor scheme 'oblivion'

fi

if [ "$XDG_CURRENT_DESKTOP" == "MATE" ]; then

	gsettings set org.mate.interface gtk-theme 'Mint-Y-Dark'
	gsettings set org.mate.interface icon-theme 'Papirus-Dark'
	gsettings set org.mate.interface monospace-font-name 'Rec Mono Semicasual 11'
	gsettings set org.mate.power-manager button-power 'hibernate'
	gsettings set org.mate.power-manager idle-dim-ac true
	gsettings set org.mate.power-manager idle-dim-battery true
	gsettings set org.mate.power-manager action-critical-battery 'hibernate'
	gsettings set org.mate.power-manager action-sleep-type-ac 'hibernate'
	gsettings set org.mate.power-manager action-sleep-type-battery 'hibernate'
	gsettings set org.mate.power-manager sleep-computer-ac 1800
	gsettings set org.mate.power-manager sleep-computer-battery 600
	gsettings set org.mate.power-manager button-lid-ac 'hibernate'
	gsettings set org.mate.power-manager button-lid-battery 'hibernate'
	gsettings set org.mate.peripherals-mouse accel-profile 'flat'
	gsettings set org.mate.peripherals-touchpad tap-to-click true
	gsettings set org.mate.peripherals-touchpad tap-button-two-finger 3
	gsettings set org.mate.peripherals-touchpad tap-button-three-finger 2
	gsettings set org.mate.peripherals-touchpad natural-scroll true
	gsettings set org.mate.peripherals-keyboard-xkb.general duplicate-leds true

	sudo cp ~/Imágenes/jowens_kauai.jpg /usr/share/backgrounds/

fi

if [ $(lsb_release -is) == "Arch" ]; then 

	mkdir ~/.config/autostart

cat > ~/.config/autostart/apparmor-notify.desktop <<EOF
[Desktop Entry]
Type=Application
Name=AppArmor Notify
Comment=Receive on screen notifications of AppArmor denials
TryExec=aa-notify
Exec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log
StartupNotify=false
NoDisplay=true
EOF

	systemctl disable --now --user gnome-keyring-daemon.socket gnome-keyring-daemon.service

fi

## Adding user to audio group
user="$USER"
sudo usermod -aG audio $user

## Configuring git
git config --global user.name "Alderaeney"
git config --global user.email "alderaeney@gmail.com"
git config --global init.defaultBranch master
git config --global credential.helper store

## Changing user shell
if ! command -v chsh &>/dev/null; then
	sudo lchsh link
else
	if [ -e /usr/bin/zsh ]; then 
		chsh -s /usr/bin/zsh
	else
		chsh -s /bin/zsh
	fi
fi
vim ~/.zshrc

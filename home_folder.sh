#!/bin/bash

_script="$(readlink -f ${BASH_SOURCE[0]})"

directory="$(dirname $_script)"

sudo cryptsetup open /dev/sda1 encrypteddata
mkdir /home/link/Datos
sudo mount /dev/mapper/encrypteddata /home/link/Datos 
sudo cp /home/link/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=20976b67-c796-47c9-90dd-62c1edc34258 /root/.keyfile luks,discard" | sudo tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata /home/link/Datos ext4 defaults 0 0" | sudo tee -a /etc/fstab

rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

ln -s /home/link/Datos/Descargas /home/link
ln -s /home/link/Datos/Descargas /home/link/Downloads
ln -s /home/link/Datos/Documentos /home/link
ln -s /home/link/Datos/Escritorio /home/link
ln -s /home/link/Datos/Música /home/link
ln -s /home/link/Datos/Imágenes /home/link
ln -s /home/link/Datos/Torrent /home/link
ln -s /home/link/Datos/Nextcloud /home/link

xdg-user-dirs-update --set DESKTOP $HOME/Datos/Escritorio
xdg-user-dirs-update --set DOCUMENTS $HOME/Datos/Documentos
xdg-user-dirs-update --set DOWNLOAD $HOME/Datos/Descargas
xdg-user-dirs-update --set MUSIC $HOME/Datos/Música
xdg-user-dirs-update --set PICTURES $HOME/Datos/Imágenes

wget https://someonewhocares.org/hosts/zero/hosts
sudo cp /etc/hosts /etc/hosts.bak
sudo mv hosts /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts
echo "::1 $(hostname) ipv6-localhost ipv6-loopback"  | sudo tee -a /etc/hosts

git clone https://github.com/kitsunyan/intel-undervolt.git
cd intel-undervolt && ./configure --enable-systemd && make && sudo make install
cd .. && sudo rm -r intel-undervolt

sudo sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sudo sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf
sudo systemctl enable intel-undervolt

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
       
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

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

cp $directory/dotfiles/.vimrc ~
mkdir -p ~/.config/nvim/
ln -s ~/.vimrc ~/.config/nvim/init.vim
nvim +PlugInstall +q +q
cd ~/.vim/plugged/youcompleteme 
python install.py 

cp $directory/dotfiles/chromium-flags.conf ~/.config

mkdir -p ~/.config/mpv/shaders/
curl -LO https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/ac09db2c0664150863e85d5a4f9f0106b6443a12/SSimDownscaler.glsl
curl -LO https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/424a8deae7d5a142d0bbbf1552a686a0421644ad/KrigBilateral.glsl
mv SSimDownscaler.glsl KrigBilateral.glsl ~/.config/mpv/shaders
cp $directory/dotfiles/mpv.conf ~/.config/mpv/

if [[ $XDG_CURRENT_DESKTOP = "GNOME" ]]; then
	mkdir ~/.themes
	cp ~/Documentos/theme.tar.xz ~/.themes && cd ~/.themes
	tar xf theme.tar.xz 
	rm theme.tar.xz
	count=$(ls | wc -l)
	if [[ $count -eq 1 ]]; then
		file=$(ls)
		gsettings set org.gnome.desktop.interface gtk-theme "$file"
		gsettings set org.gnome.desktop.wm.preferences theme "$file"
		count=$(gnome-extensions list | grep user-theme | wc -l)
		if [[ $count -eq 1 ]]; then
			gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
			gsettings set org.gnome.shell.extensions.user-theme name "$file"
		fi
	fi
	count=$(ls /usr/share/icons/ | grep "Papirus" | wc -l)
	if [[ $count -gt 0 ]]; then
		gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
	fi
fi

hostnm=$(cat /etc/hostname)

mkdir -p ~/.config/Yubico

echo "Insert FIDO2 card and press a key:"
read -n 1
pamu2fcfg -o pam://"$hostnm" -i pam://"$hostnm" > ~/.config/Yubico/u2f_keys
echo "Remove FIDO2 car and insert another, then press a key:"
read -n 1
pamu2fcfg -o pam://"$hostnm" -i pam://"$hostnm" -n >> ~/.config/Yubico/u2f_keys
sudo sed -i "2i auth            required      pam_u2f.so origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/sudo
sudo sed -i "/auth.*substack.*system-auth/a auth\tsufficient\tpam_u2f.so cue origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/su
if [ -e /etc/pam.d/gdm-password ]; then
	sudo cp /etc/pam.d/gdm-password /etc/pam.d/gdm-password.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
	if diff /etc/pam.d/gdm-password.bak gdm-password ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
		sudo cp gdm-password /etc/pam.d/gdm-password
	else
		sudo cp gdm-password /etc/pam.d/gdm-password
	fi
fi

if [ -e /etc/pam.d/sddm ]; then
	sudo sed -i "2i auth required pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm" /etc/pam.d/sddm 
fi

if [ -e /etc/pam.d/kde ]; then
	sudo sed -i "2i auth required pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm" /etc/pam.d/kde
fi

if [ -e /etc/pam.d/polkit-1 ]; then
	sudo sed -i "2i auth required pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm" /etc/pam.d/polkit-1
fi

mkdir ~/.fonts
cd ~/.fonts
unzip ~/Documentos/fonts.zip

git config --global user.name "Alderaeney"
git config --global user.email "sariaaskort@tuta.io"
git config --global init.defaultBranch master

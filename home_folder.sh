#!/bin/bash

sudo cryptsetup open /dev/sda1 encrypteddata
mkdir /home/link/Datos
sudo mount /dev/mapper/encrypteddata /home/link/Datos -o compress=zstd
sudo cp /home/link/Datos/.keyfile /root/.keyfile
echo "encrypteddata UUID=e5622fea-e408-4595-96b0-afc3ea362e64 /root/.keyfile luks,discard" | sudo tee -a /etc/crypttab
echo "/dev/mapper/encrypteddata /home/link/Datos btrfs compress=zstd:3,defaults 0 0" | sudo tee -a /etc/fstab

rm -r ~/Descargas ~/Documentos ~/Escritorio ~/Música ~/Imágenes ~/Downloads ~/Torrent

ln -s /home/link/Datos/Descargas /home/link
ln -s /home/link/Datos/Descargas /home/link/Downloads
ln -s /home/link/Datos/Documentos /home/link
ln -s /home/link/Datos/Escritorio /home/link
ln -s /home/link/Datos/Música /home/link
ln -s /home/link/Datos/Imágenes /home/link
ln -s /home/link/Datos/Torrent /home/link
ln -s /home/link/Datos/Nextcloud /home/link

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

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

cp .zshrc ~
cp .general_alias ~
cp .arch_alias ~ 
cp .debian_alias ~
cp .fedora_alias ~
cp .vimrc ~
cp .opensuse_alias ~


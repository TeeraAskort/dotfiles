#!/usr/bin/env bash

if [ "$1" == "gnome" ] || [ "$1" == "kde" ] || [ "$1" == "plasma" ] || [ "$1" == "xfce" ]; then
	# Adding 32bit support
	dpkg --add-architecture i386
	apt update

	# Installing drivers
	apt install firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

	# Adding xanmod kernel
	echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list
	wget -qO - https://dl.xanmod.org/gpg.key | apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
	apt update && apt install -y linux-xanmod intel-microcode iucode-tool
	echo 'net.core.default_qdisc = fq_pie' | tee /etc/sysctl.d/90-override.conf
	
	# Adding vivaldi repo
	wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | apt-key add -
	add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main' 
	apt update
	
	# Installing strawberry
	curl -s https://api.github.com/repos/strawberrymusicplayer/strawberry/releases/latest \
	| grep "browser_download_url" \
	| grep "strawberry_" \
	| grep "bullseye" \
	| cut -d '"' -f 4 \
	| wget -O strawberry.deb -qi -
	apt install -y ./strawberry.deb
	
	# Installing wine
	wget -nc https://dl.winehq.org/wine-builds/winehq.key
	apt-key add winehq.key
	echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" | tee /etc/apt/sources.list.d/wine.list
	apt update && apt install -y winehq-staging winetricks

	# Installing VSCode
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
	echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
	rm -f packages.microsoft.gpg
	apt install apt-transport-https && apt update
	apt install -y code
	
	# Add deb-multimedia repo
	echo "deb https://www.deb-multimedia.org bullseye main non-free" | tee /etc/apt/sources.list.d/multimedia.list
	apt-get update -oAcquire::AllowInsecureRepositories=true
	apt-get install -y deb-multimedia-keyring
	apt update && apt full-upgrade -y

	# Installing required applications
	apt install -y build-essential steam vivaldi-stable vim nano fonts-noto fonts-noto-cjk fonts-noto-mono pcsx2 mednafen mednaffe telegram-desktop nodejs npm neovim python3-neovim gimp flatpak papirus-icon-theme zsh zsh-autosuggestions zsh-syntax-highlighting thermald mpv youtube-dl 
	
	systemctl enable thermald
	
	# Removing unused applications
	apt remove -y firefox-esr 
	
	if [ "$1" == "gnome" ]; then
		# Installing required packages
		apt install materia-gtk-theme qt5-qmake qtbase5-private-dev libgtk2.0-0 libx11-6 ffmpegthumbnailer tilix transmission-gtk evolution aisleriot gnome-mahjongg 
		
		# Installing qt5gtk2
		git clone https://bitbucket.org/trialuser02/qt5gtk2.git
		cd qt5gtk2
		qmake && make && make install
		cd .. && rm -r qt5gtk2
		echo "QT_QPA_PLATFORMTHEME=qt5gtk2" | tee -a /etc/environment
		
		# Remove unwanted applications
		apt remove -y totem rhythmbox 
		
	elif [ "$1" == "kde" ] || [ "$1" == "plasma" ]; then
		# Installing required packages
		apt install -y qbittorrent palapeli kmahjongg kpat thunderbird yakuake 
		
		# Remove unwanted applications
		apt remove -y konversation akregator 
		
	elif [ "$1" == "xfce" ]; then
		# Installing required packages
		apt install -y tilix gvfs gvfs-backends thunderbird materia-gtk-theme qt5-qmake qtbase5-private-dev libgtk2.0-0 libx11-6 ffmpegthumbnailer tumbler tumbler-plugins-extra transmission-gtk
		
		# Installing qt5gtk2
		git clone https://bitbucket.org/trialuser02/qt5gtk2.git
		cd qt5gtk2
		qmake && make && make install
		cd .. && rm -r qt5gtk2
		echo "QT_QPA_PLATFORMTHEME=qt5gtk2" | tee -a /etc/environment
	fi
	
	# Removing unused packages
	apt autoremove -y
	
	#Add flathub repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	#Install flatpak applications
	flatpak install -y flathub com.discordapp.Discord io.lbry.lbry-app org.jdownloader.JDownloader

	# Installing angular globally
	npm i -g @angular/cli @ionic/cli firebase-tools
	ng analytics off

else
	echo "Accepted paramenters:"
	echo "kde or plasma - to configure the plasma desktop"
	echo "gnome - to configure the GNOME desktop"
	echo "xfce - to configure the XFCE desktop"
fi


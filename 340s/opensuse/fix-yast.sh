#!/usr/bin/env bash

sed -i "s/\/usr\/bin\/xdg-su -c \/sbin\/yast2/\/usr\/local\/sbin\/yast2_polkit/g" /usr/share/applications/org.opensuse.YaST.desktop

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

cd /usr/share/applications/YaST2

for file in $(ls /usr/share/applications/YaST2); do 
	if [ -f $file ]; then
		sed -i "s/\"//g" $file
		sed -i "s/'//g" $file
		sed -i "s/\/usr\/bin\/xdg-su -c \/sbin\/yast2/\/usr\/local\/sbin\/yast2_polkit/g" $file
		sed -i "s/xdg-su -c \/sbin\/yast2/\/usr\/local\/sbin\/yast2_polkit/g" $file
	fi 
done

IFS=$SAVEIFS

#!/usr/bin/env bash

sed -i "s/xdg-su -c/pkexec/g" /usr/share/applications/org.opensuse.YaST.desktop

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

cd /usr/share/applications/YaST2

for file in $(ls /usr/share/applications/YaST2); do 
	sed -i "s/xdg-su -c/pkexec/g" $file
	sed -i "s/\"//g" $file
done

IFS=$SAVEIFS

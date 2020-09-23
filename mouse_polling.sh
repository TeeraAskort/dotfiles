#!/bin/bash

if [ -f /etc/modprobe.d/usbhid.conf ]; then
	value=$(cat /etc/modprobe.d/usbhid.conf | cut -d"=" -f2)
	echo "Actual value $value changing value"
	if [ $value = 1 ]; then 
		sed -i "s/1/8/" /etc/modprobe.d/usbhid.conf
	else
		sed -i "s/8/1/" /etc/modprobe.d/usbhid.conf
	fi
else
	echo "options usbhid mousepoll=1" | tee /etc/modprobe.d/usbhid.conf
fi

modprobe -r usbhid && modprobe usbhid

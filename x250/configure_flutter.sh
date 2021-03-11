#!/bin/env bash 

## Configuring flutter
if command -v flutter &> /dev/null
then
	flutter sdk-path

	flutter config --android-sdk /home/link/Datos/Android
else
	sudo snap install flutter --classic

	flutter sdk-path

	flutter config --android-sdk /home/link/Datos/Android

fi

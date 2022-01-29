hostnm=$(hostname)

if [ -e /etc/pam.d/sudo ]; then
	sudo sed -i "2i auth            sufficient      pam_u2f.so origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/sudo
fi

if [ -e /etc/pam.d/su ]; then
	sudo sed -i "/auth.*substack.*system-auth/a auth\tsufficient\tpam_u2f.so cue origin=pam://$hostnm appid=pam://$hostnm cue" /etc/pam.d/su
fi

if [ -e /etc/pam.d/common-auth ]; then
	sudo sed -i "s/pam_env.so/&\nauth    required        pam_u2f.so      cue/g" /etc/pam.d/common-auth
fi

if [ -e /etc/pam.d/gdm-password ]; then
	sudo cp /etc/pam.d/gdm-password /etc/pam.d/gdm-password.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
	if diff /etc/pam.d/gdm-password.bak gdm-password ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/gdm-password /etc/pam.d/gdm-password > gdm-password
		sudo cp gdm-password /etc/pam.d/gdm-password
	else
		sudo cp gdm-password /etc/pam.d/gdm-password
	fi
	rm gdm-password
fi

if [ -e /etc/pam.d/xfce4-screensaver ]; then
	sudo cp /etc/pam.d/xfce4-screensaver /etc/pam.d/xfce4-screensaver.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/xfce4-screensaver /etc/pam.d/xfce4-screensaver > xfce4-screensaver
	if diff /etc/pam.d/xfce4-screensaver.bak xfce4-screensaver ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/xfce4-screensaver /etc/pam.d/xfce4-screensaver > xfce4-screensaver
		sudo cp xfce4-screensaver /etc/pam.d/xfce4-screensaver
	else
		sudo cp xfce4-screensaver /etc/pam.d/xfce4-screensaver
	fi
	rm xfce4-screensaver
fi

if [ -e /etc/pam.d/lightdm ]; then
	sudo cp /etc/pam.d/lightdm /etc/pam.d/lightdm.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/lightdm /etc/pam.d/lightdm > lightdm
	if diff /etc/pam.d/lightdm.bak lightdm ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/lightdm /etc/pam.d/lightdm > lightdm
		sudo cp lightdm /etc/pam.d/lightdm
	else
		sudo cp lightdm /etc/pam.d/lightdm
	fi
	rm lightdm
fi

if [ -e /etc/pam.d/cinnamon-screensaver ]; then
	sudo cp /etc/pam.d/cinnamon-screensaver /etc/pam.d/cinnamon-screensaver.bak
	awk -v exclude="#" '($0 !~ exclude) &&  FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth            required      pam_u2f.so nouserok cue" }' /etc/pam.d/cinnamon-screensaver /etc/pam.d/cinnamon-screensaver > cinnamon-screensaver
	sudo cp cinnamon-screensaver /etc/pam.d/cinnamon-screensaver
	rm cinnamon-screensaver
fi

if [ -e /etc/pam.d/sddm ]; then
	sudo cp /etc/pam.d/sddm /etc/pam.d/sddm.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
	if diff /etc/pam.d/sddm.bak sddm ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/sddm /etc/pam.d/sddm > sddm
		sudo cp sddm /etc/pam.d/sddm
	else
		sudo cp sddm /etc/pam.d/sddm
	fi
	rm sddm
fi

if [ -e /etc/pam.d/kde ]; then
	sudo cp /etc/pam.d/kde /etc/pam.d/kde.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/kde /etc/pam.d/kde > kde
	if diff /etc/pam.d/kde.bak kde ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/kde /etc/pam.d/kde > kde
		sudo cp kde /etc/pam.d/kde
	else
		sudo cp kde /etc/pam.d/kde
	fi
	rm kde
fi

if [ -e /etc/pam.d/polkit-1 ]; then
	sudo cp /etc/pam.d/polkit-1 /etc/pam.d/polkit-1.bak
	awk "FNR==NR{ if (/auth /) p=NR; next} 1; FNR==p{ print\"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
	if diff /etc/pam.d/polkit-1.bak polkit-1 ; then
		awk "FNR==NR{ if (/auth\t/) p=NR; next} 1; FNR==p{ print \"auth            required      pam_u2f.so nouserok origin=pam://$hostnm appid=pam://$hostnm\" }" /etc/pam.d/polkit-1 /etc/pam.d/polkit-1 > polkit-1
		sudo cp polkit-1 /etc/pam.d/polkit-1
	else
		sudo cp polkit-1 /etc/pam.d/polkit-1
	fi
	rm polkit-1
fi

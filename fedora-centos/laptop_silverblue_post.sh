#!/bin/bash

# Installing nvidia drivers
rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda mozilla-openh264 gstreamer1-plugin-openh264 ffmpeg mpv lutris gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav gstreamer1-plugins-good-extras ffmpegthumbnailer gstreamer1-plugins-bad-free-extras chromium-freeworld

# Appending kernel parameters for nvidia
rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau

# Editing intel-undervolt config
sed -i "s/undervolt 0 'CPU' 0/undervolt 0 'CPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 1 'GPU' 0/undervolt 1 'GPU' -100/g" /etc/intel-undervolt.conf
sed -i "s/undervolt 2 'CPU Cache' 0/undervolt 2 'CPU Cache' -100/g" /etc/intel-undervolt.conf

# Enable intel-undervolt
systemctl enable intel-undervolt tlp tomcat

# Changing tlp config
sed -i "s/#CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance/CPU_ENERGY_PERF_POLICY_ON_AC=balance_power/g" /etc/tlp.conf
sed -i "s/#SCHED_POWERSAVE_ON_AC=0/SCHED_POWERSAVE_ON_AC=1/g" /etc/tlp.conf

# Add tomcat exception to firewall
firewall-cmd --permanent --add-port=8080/tcp

# Enable Dynamic Power Management
cat > /etc/modprobe.d/nvidia.conf <<EOF
# Enable DynamicPwerManagement
# http://download.nvidia.com/XFree86/Linux-x86_64/435.17/README/dynamicpowermanagement.html
options nvidia NVreg_DynamicPowerManagement=0x02
EOF

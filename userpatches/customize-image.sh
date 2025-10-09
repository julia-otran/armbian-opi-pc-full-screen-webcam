#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
	locale-gen en_US.UTF-8

	echo "root:weloveopi" | chpasswd

	apt update

	apt install -y make gcc build-essential libjson-c-dev libv4l-dev libdrm-dev ufw iproute2 nginx

	groupadd video

	cp /tmp/overlay/99-cedar-allow.rules /etc/udev/rules.d
	cp /usr/src/linux-headers-6.13.7-edge-sunxi/include/uapi/drm/sun4i_drm.h /usr/include/drm

	groupadd webcam
	useradd -m -d /home/webcam -g webcam -G video -s /bin/bash webcam

	chown webcam:webcam /home/webcam

	cp -R /tmp/overlay/camview /home/webcam

	cd /home/webcam/camview

	make
	make install

	chown -R webcam:webcam /home/webcam

	mkdir /scripts
	cp /tmp/overlay/webcam-view.sh /scripts
	chown webcam:video /scripts/webcam-view.sh

	cp /tmp/overlay/webcam.service /lib/systemd/system/webcam.service

	systemctl enable webcam

	ufw allow from 172.3.0.0/24 to any port 22
	ufw allow from 172.3.0.0/24 to any port 80
	ufw enable

	cp /tmp/overlay/nginx-default /etc/nginx/sites-available/default

	usermod -a -G www-data webcam

	cp -R /tmp/overlay/remote-ctl/build/. /var/www/html

	mkdir -p /var/www/camview
	chown www-data:www-data /var/www/camview
	chmod 770 /var/www/camview

	rm /root/.not_logged_in_yet

	sed -i '/console=/d' /boot/armbianEnv.txt
	echo 'console=ttyS0,115200' >> /boot/armbianEnv.txt
	echo 'options uvcvideo quirks=0x880' > /etc/modprobe.d/uvcvideo.conf
}

Main "$0"

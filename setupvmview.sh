#!/bin/bash

#Setup script to configure vmware-view client in ltsp-chroot
ARCH=$1
CHROOT="/opt/ltsp/$ARCH"

if [ -z $ARCH ]; then
	echo usage : ./setupvmview.sh ltsparch_path
	exit 1;
fi

if [ ! -d $CHROOT ]; then
	echo /opt/ltsp/$1 is not a valid path
	exit 1;
fi

CLIENT_BUNDLE=`ls VMware-Horizon-Client*.bundle 2> /dev/null`

if [ -z $CLIENT_BUNDLE ]; then
	echo "VMware-Horizon-Client bundle file not Found";
	echo "please visit http://www.vmware.com/go/viewclients and download last release for Linux";
	exit 1;
fi


if [ ! -f  $CHROOT/root/$CLIENT_BUNDLE ]; then
	echo "Found $CLIENT_BUNDLE try to install it"
	cp $CLIENT_BUNDLE $CHROOT/root/
	chmod a+x $CHROOT/root/$CLIENT_BUNDLE
	ltsp-chroot --arch $ARCH  /root/$CLIENT_BUNDLE
else
	echo "$CLIENT_BUNDLE already present in chroot"
	echo "Continue"
fi

for i in libxss1 openssl x11vnc
do
	echo install dependency $i
	ltsp-chroot --arch $ARCH apt-get install $i
done

echo "link libraries"
ltsp-chroot  --arch $ARCH ln -s /usr/lib/vmware/view/usb/libssl.so.1.0.1 /lib/i386-linux-gnu/libssl.so.1.0.1
ltsp-chroot  --arch $ARCH ln -s /usr/lib/vmware/view/usb/libcrypto.so.1.0.1 /lib/i386-linux-gnu/libcrypto.so.1.0.1


echo "copy root profile"
cp -rv root $CHROOT/

echo "copy ltsp scripts"
cp -rv xinitrc.d $CHROOT/usr/share/ltsp/
cp -rv screen.d $CHROOT/usr/share/ltsp/

echo "change kernel generator config"
cp -rv etc/ltsp/* $CHROOT/etc/ltsp/
ltsp-chroot --arch $ARCH /usr/share/ltsp/update-kernels

if [ ! -f /etc/ltsp/ltsp-update-images.exclude.bak ]; then
echo "change update-image conf"
cp /etc/ltsp/ltsp-update-image.exclude /etc/ltsp/update-image.exclude.bak
cp etc/ltsp/ltsp-update-image.exclude /etc/ltsp/
fi

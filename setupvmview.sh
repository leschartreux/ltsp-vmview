#!/bin/bash

#Setup script to configure vmware-view client in ltsp-chroot
DIR=$1
if [ -z $2 ]; then
	ARCH=amd64
else
	ARCH=$2
fi

CHROOT="/opt/ltsp/$DIR"
VMVIEW_PATH="/usr/lib/vmware/view/"
TFTPDIR="/var/lib/tftpboot"

if [ -z $DIR ]; then
	echo "Please specify a depot directory (ex: ./setupvmview.sh i386-vmview)"
	exit 1;
fi

if [ ! -d $CHROOT ]; then
	echo /opt/ltsp/$DIR is not a valid path
	echo Please first build default ltsp client with "ltsp-build-client --chroot $DIR --arch $ARCH"
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
	ltsp-chroot --arch $DIR  /root/$CLIENT_BUNDLE --console --eulas-agreed \
	    --stop-service \
	    --set-setting vmware-horizon-usb usbEnable yes \
	    --set-setting vmware-horizon-virtual-printing tpEnable no \
	    --set-setting vmware-horizon-smartcard smartcardEnable no \
	    --set-setting vmware-horizon-rtav rtavEnable yes \
	    --set-setting vmware-horizon-tsdr tsdrEnable no
	      
else
	echo "$CLIENT_BUNDLE already present in chroot"
	echo "Continue"
fi

#REquired packages for vmware-view
for i in libxss1 openssl openssh-server x11vnc hsetroot openbox
do
	echo install package $i
	ltsp-chroot --arch $DIR apt-get install $i --yes
done

echo "link libraries"
if [ ! -f "$CHROOT/$VMVIEW_PATH/libssl.so.1" ]; then
	ltsp-chroot  --arch $DIR ln -s /usr/lib/vmware/view/usb/libssl.so.1.0.1 /lib/$ARCH-linux-gnu/libssl.so.1.0.1
fi
if [ ! -f "$CHROOT/$VMVIEW_PATH/libcrypto.so.1.0.1" ]; then
	ltsp-chroot  --arch $DIR ln -s /usr/lib/vmware/view/usb/libcrypto.so.1.0.1 /lib/$ARCH-linux-gnu/libcrypto.so.1.0.1
fi
if [ ! -f "$CHROOT/$VMVIEW_PATH/libudev.so.0" ]; then
	ltsp-chroot  --arch $DIR ln -s /lib/$ARCH-linux-gnu/libudev.so.1 /lib/$ARCH-linux-gnu/libudev.so.0
fi


echo "copy root profile"
cp -rv root $CHROOT/

echo "copy ltsp scripts"
cp -rv xinitrc.d $CHROOT/usr/share/ltsp/
cp -rv screen.d $CHROOT/usr/share/ltsp/

echo "Change kernel generator config"
if [ ! -d $CHROOT/etc/ltsp ]; then
	mkdir $CHROOT/etc/ltsp
fi
if [ -f etc/ltsp/update-kernel.conf ]; then
	cp etc/ltsp/update-kernel.conf $CHROOT/etc/ltsp/
	ltsp-chroot --arch $DIR /usr/share/ltsp/update-kernels
fi

#Needed to include root home dir into squashfs image (unbuntu)
if [ -f /etc/ltsp/ltsp-update-image.excludes ]; then
	echo "Change update-image exlcudes"
	if [ ! -f /etc/ltsp/update-image.excludes.bak ]; then
		cp /etc/ltsp/ltsp-update-image.excludes /etc/ltsp/update-image.excludes.bak
		cp etc/ltsp/ltsp-update-image.excludes /etc/ltsp/
	fi
fi

if [ ! -f $TFTPDIR/ltsp/$DIR/lts.conf ]; then
	echo "copy lts.conf file in TFTP root"
	cp lts.conf $TFTPDIR/ltsp/$DIR/lts.conf
fi


echo "**************************"
echo "SETUP FINISHED !"
echo "**************************"
echo "things to be done : "
echo "	1) edit view.autoconnectBroker in $CHROOT/root/.vmware/view-preferences"
echo ""
echo "	2) optionally add a VNC password to access screen remotely :"
echo "ltsp-chroot --arch $DIR x11vnc -storepasswd /root/.config/openbox/.vncpass"
echo ""
echo "	3) optionally create root password for console or SSH access:"
echo "ltsp-chroot --arch $DIR passwd"
echo ""
echo "	4) rebuild your squashfs image with"
echo "ltsp-update-image $DIR"
echo ""
echo "	5) edit Broker IP in $TFTPDIR/ltsp/$DIR/lts.conf"
echo 
echo "	6) Configure some thin client in your dhcpd.conf (isc-dhcp-server) by adding those parameters : "
echo "		next-server ltsp_server_ip;"
echo "		filename \"ltsp/$DIR/pxelinux.0\";"
echo
echo Enjoy !

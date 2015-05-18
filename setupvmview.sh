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


echo "Found $CLIENT_BUNDLE try to install it"
cp $CLIENT_BUNDLE $CHROOT/root/
chmod a+x $CHROOT/root/$CLIENT_BUNDLE
ltsp-chroot --arch $ARCH  /root/$CLIENT_BUNDLE

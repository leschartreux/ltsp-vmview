#!/bin/bash

#Setup script to configure vmware-horizon-view dedicated client 
#version for Ubuntu PNP and FAT_CLIENT
# see https://help.ubuntu.com/community/UbuntuLTSP/ltsp-pnp


DIR=$1
ARCH=i386
CHROOT=""
VMVIEW_PATH="/usr/lib/vmware/"
TFTPDIR="/var/lib/tftpboot"
SETUP_ARGS_FILE="vhc-setup-args-new.conf"

CLIENT_BUNDLE=`ls VMware-Horizon-Client*.bundle 2> /dev/null`

echo "---------------------------------------------------------------------------"
#Check if Client Bundle is downloaded
if [ -z $CLIENT_BUNDLE ]; then
	echo "VMware-Horizon-Client bundle file not Found";
	echo "please visit http://www.vmware.com/go/viewclients and download last release for Linux";
	exit 1;
fi

#Version specific settings and librairies
. $SETUP_ARGS_FILE


if [ ! -d  $VMVIEW_PATH ]; then
	echo "Found $CLIENT_BUNDLE try to install it"
	cp $CLIENT_BUNDLE $CHROOT/root/
	chmod a+x $CHROOT/root/$CLIENT_BUNDLE
	if [ ! -f $SETUP_ARGS_FILE ]; then
		echo "$SETUP_ARGS_FILE Not found. Can't install"
	else
		/root/$CLIENT_BUNDLE $VMSETUP_ARGS
	fi
	      
else
	echo "$CLIENT_BUNDLE already present in /root"
	echo "Continue"
fi

echo "---------------------------------------------------------------------------"
#REquired packages for vmware-view
for i in ltsp ltsp-binaries dnsmasq nfs-kernel-serveR openssh-server quashfs-tools net-tools x11vnc hsetroot openbox
do
	echo install package $i
	apt-get install $i --yes
done
echo "---------------------------------------------------------------------------"

echo install dependencies librairies
apt-get install $VMW_DEPENDENCIES --yes
echo "--------------------------------------------------------------------------"

#generate lib symlinks from VM_OLDLIBS Var
for l in $VMW_LIBLINKS
do
	echo "link librairies"
	LD=`echo $l | cut -d"=" -f1`
	LS=`echo $l | cut -d"=" -f2`        
	
	if [ ! -f "$CHROOT/$LD" ]; then

		echo "ln -s $LS $CHROOT$LD"
		ln -s $LS $CHROOT$LD
	fi
done
echo "---------------------------------------------------------------------------"



if [ ! -d /home/vmview ]; then
	echo creating new user localuser
	useradd -m vmview
	echo "vmview:windows" | chpasswd
fi
echo "copy localuser profile"
cp -av localuser $CHROOT/home/vmview
echo "---------------------------------------------------------------------------"

#echo "copy ltsp scripts"
#cp -rv xinitrc.d $CHROOT/usr/share/ltsp/
#cp -rv screen.d $CHROOT/usr/share/ltsp/
#echo "---------------------------------------------------------------------------"


#echo "Change kernel generator config"
#if [ ! -d $CHROOT/etc/ltsp ]; then
#	mkdir $CHROOT/etc/ltsp
#fi
#if [ -f etc/ltsp/update-kernel.conf ]; then
#	cp etc/ltsp/update-kernel.conf $CHROOT/etc/ltsp/
#	ltsp-chroot --arch $DIR /usr/share/ltsp/update-kernels
#fi

#Needed to include root home dir into squashfs image (unbuntu)
#echo "---------------------------------------------------------------------------"
#if [ -f /etc/ltsp/ltsp-update-image.excludes ]; then
#	echo "Change update-image exlcudes"
#	if [ ! -f /etc/ltsp/update-image.excludes.bak ]; then
#		cp /etc/ltsp/ltsp-update-image.excludes /etc/ltsp/update-image.excludes.bak
#		cp etc/ltsp/ltsp-update-image.excludes /etc/ltsp/
#	fi
#fi

#if [ ! -f $TFTPDIR/ltsp/$ARCH/lts.conf ]; then
#	echo "copy lts.conf file in TFTP root"
#	cp lts.conf $TFTPDIR/ltsp/$ARCH/lts.conf
#fi
#echo "---------------------------------------------------------------------------"


echo "**************************"
echo "SETUP FINISHED !"
echo "**************************"
echo "things to be done : "
echo "	1) edit view.autoconnectBroker in /home/localuser/.vmware/view-preferences"
echo ""
echo "	2) optionally add a VNC password to access screen remotely :"
echo "x11vnc -storepasswd /home/localuser/.config/openbox/.vncpass"
echo ""
#echo "	3) optionally create root password for console or SSH access:"
#echo "ltsp-chroot --arch $DIR passwd"
#echo ""
echo "	3) rebuild your squashfs image with"
echo "ltsp-update-image --cleanup /"
echo ""
echo "	4) edit Broker IP in $TFTPDIR/ltsp/$ARCH/lts.conf"
echo 
echo "	5) Configure some thin client in your dhcpd.conf (isc-dhcp-server) by adding those parameters : "
echo "		next-server ltsp_server_ip;"
echo "		filename \"ltsp/$ARCH/pxelinux.0\";"
echo
echo Enjoy !

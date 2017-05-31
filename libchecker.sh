#!/bin/bash

#Check librairies with installed componets of vmware Horizon Client

VMW_COMPONENTS="vmware-horizon-smartcard vmware-horizon-rtav vmware-horizon-tsdr vmware-horizon-mmr vmware-horizon-pcoip vmware-horizon-usb vmware-horizon-virtual-printing vmware-horizon-client"


for c in $VMW_COMPONENTS
do
	echo "MISSING LIB in $c"
	ldd $(vmware-installer -L $c) | grep found
	echo "----------------"
done

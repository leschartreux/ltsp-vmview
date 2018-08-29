#!/bin/bash

if [ ! -x /usr/sbin/add-apt-repository ]
then
	apt install --yes software-properties-common
fi

add-apt-repository   --yes ppa:ts.sch.gr
apt update
apt install --yes ltsp-server

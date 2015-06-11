# ltsp-vmview
ltsp-vmview is a shell script to build Linux Diskless Thin Client for *Vmware Horizon View*.

Recent releases of *Vmware Horizon View Client* for Linux are now *full feartured*. This make a good choice to access *Vmware View Brokers* from Linux Desktops.

LTSP (Linux Terminal Server Project) is the best Diskless Thin Client solution. Originally designed for remote Linux desktops sessions, but fully customizable.
  More info on http://ltsp.org.

## Features
Allow full access to virtual desktop pools available via the brokers.
Launches a tiny *openbox* window manager with right click menu to launch xterm (for test and debug) or view client.
view client starts automatically and connects to configured default View broker.

* *PCoIP* support
* USB redirection
* Audio-Video support

## Requirements

- A small PC as server with network, or free space to install as Virtual Machine.
64 or 32 bit processor. Multi core is better to speed up images building.
6GB free space on Hard drive is enough.

- *Ubuntu server* Setup CD. *Ubuntu 14.04* iso from here http://www.ubuntu.com/download/server. Or an existing Ubuntu LTS installation.

- Any configurable DHCP server. *isc-dhcp-server* is a good one.

- Some old (or new) PCs with boot on LAN capabilities. It works as Live CD so already installed systems are not affected.


## Quick Setup
- Perform a minimum install of *Ubuntu Server* Without additional packages.

- login as admin account and set a password for root to avoid many ```sudo```.

```
sudo su
passwd
```

- Install *ltsp-server* package as usally.

```
apt-get install ltsp-server
```

- Install git then clone ltsp-vmview project from github
```
apt-get install git
mkdir git
git clone https://github.com/leschartreux/ltsp-vmview.git
```

- go to http://www.vmware.com/go/viewclients and download last release of *View Client* for Linux. This is a *.bundle* file. Put it in project's root.

- choose a name for your thin client directory (ex : *ltsp-vmview*) and build a default thin client.
```
ltsp-build-client --arch i386 --chroot ltsp-vmview --dist precise
```
In my case Precise (12.04) release from Ubuntu, has better pulseaudio (sound server) as it consumes less CPU. 32bits architecture is mandatory as View Clien binaries are 32bits, and for better compatibility with thin PC hardware. Process is quite long depends on Internet bandwidth. But full client root is less than 1GB.

- Once default ltsp client has built, cd to root's project then launch
setup script to configure the client.
```
./setupvmview.sh
```

- Just follow Instructions. It will install View Client in thin client chroot. You will have to agree Vmware's licenses then answer questions. In order **yes**, **no**,**yes**,**no**. Last question must be **no** as it can't verify correct setup. Here's the output :

```
Do you agree? [yes/no]: yes

Would you like to install USB Redirection?(The USB component enables USB device redirection from your local computer to the remote desktop.) [yes]:

Would you like to install Smart Card?(The Smart Card component enables Smart Card device redirection from your local computer to the remote desktop.) [yes]: no

Would you like to install Real-Time Audio-Video?(The Real-Time Audio-Video component allows you to use local computer's webcam or microphone on the remote desktop.) [yes]:

Would you like to install Virtual Printing?(The Virtual Printing component allows you to use local or network printers from a remote desktop without requiring that additional print drivers be installed
    in the remote desktop.) [yes]: no

The product is ready to be installed:
 USB Redirection
 PCoIP
 Real-Time Audio-Video
 View Client
Press Enter to begin installation or Ctrl-C to cancel.

Installing VMware Horizon Client 3.2.0
Configuring...
[######################################################################] 100%
Installation was successful.
Do you want to check your system compatibilities for Horizon Client,
this Scan will NOT collect any of your data?[yes/no]: no
```

**With 3.4 version of client and above**, Installer asks about USB install as service. Just answer no as it is in autostart.

- Then script will install missings librairies and other stuffs in thin client.

- Last, just follow Instructions at end of script to complete setup.

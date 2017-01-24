#!/bin/bash
# Author: Roger Creasy
# Email roger@rogercreasy.com
# Script to automate Ubuntu updates

# Confirm that I am running as root
if [ $EUID -ne 0 ] ; then
    clear
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "This script must run as root. Exiting...." 1>&2
    echo ""
    sleep 4
    exit 1
fi

# Startup message
clear
echo "#######################################################"
echo "#                                                     #"
echo "#            UbuntuMaintenance v.01                   #"
echo "#                      ~                              #"
echo "#                                                     #"
echo "# Welcome this app performs some very basic           #"
echo "# maintenance functions, typically ran from the       #"
echo "# line individually                                   #"
echo "#                                                     #"
echo "# Commands that are run:         	                    #"
echo "#    apt update                                       #"
echo "#    apt -y full-upgrade                              #"
echo "#    apt-get -y --purge autoremove                    #"
echo "#    apt remove --purge (remove old kernels, keep 2   #"
echo "#    remove unused config files                       #"
echo "#    remove defunct package files                     #"
echo "#######################################################"
echo
echo " Starting in 10 seconds... Hit ctrl-C to abort"

sleep 11
echo "#########################"
echo "#       Running....     #"
echo "#########################"
echo

## Update package lists
sudo apt update;
echo
echo "###############################"
echo "# Package lists updated       #"
echo "###############################"
sleep 2

## Update libraries
sudo apt -y full-upgrade;
echo
echo "###############################################"
echo "# Libraries updated"
echo "###############################################"
sleep 2
echo

## Removes unneeded packages
sudo apt-get -y --purge autoremove;
echo
echo "###################################"
echo "# Unused packages purged          #"
echo "###################################"
sleep 2
echo

# purge-old-kernels - remove old kernel packages
#    Copyright (C) 2012 Dustin Kirkland <kirkland -(at)- ubuntu.com>
#
#    Authors: Dustin Kirkland <kirkland-(at)-ubuntu.com>
#             Kees Cook <kees-(at)-ubuntu.com>
#
# NOTE: This script will ALWAYS keep the currently running kernel
# NOTE: Default is to keep 2 more, user overrides with --keep N
KEEP=2
# NOTE: Any unrecognized option will be passed straight through to apt
APT_OPTS=
while [ ! -z "$1" ]; do
	case "$1" in
		--keep)
			# User specified the number of kernels to keep
			KEEP="$2"
			shift 2
		;;
		*)
			APT_OPTS="$APT_OPTS $1"
			shift 1
		;;
	esac
done

# Build our list of kernel packages to purge
CANDIDATES=$(ls -tr /boot/vmlinuz-* | head -n -${KEEP} | grep -v "$(uname -r)$" | cut -d- -f2- | awk '{print "linux-image-" $0 " linux-headers-" $0}' )
for c in $CANDIDATES; do
	dpkg-query -s "$c" >/dev/null 2>&1 && PURGE="$PURGE $c"
done

if [ -z "$PURGE" ]; then
	echo "No kernels are eligible for removal"
fi

sudo apt $APT_OPTS remove -y --purge $PURGE;

echo
echo "##########################################"
echo "# Old kernels purged (latest 2 retained) #"
echo "##########################################"
sleep 2
echo
## Remove unused config files
sudo deborphan -n --find-config | xargs sudo apt-get -y --purge autoremove;
echo
echo "#####################################"
echo "# Unused config files purged        #"
echo "#####################################"
sleep 1
echo

## Remove package files that can no longer be downloaded retain
# the lock file and directories in /var/cache/apt/archives
sudo apt-get -y autoclean;
sudo apt-get -y clean;
echo
echo "########################################"
echo "# Purged downloaded temporary packages #"
echo "########################################"
echo

sleep 2
echo "#########################"
echo "          Done"
echo "#########################"
## EOF


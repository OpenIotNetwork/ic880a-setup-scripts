#!/bin/bash -e
#title           :04-install-add-packages.sh
#description     :This script installes additional software on your gateways..
#author          :cabbage (bernhard@openiot.at)
#usage           :bash 04-install-all-packages.sh
#notes           :This script relies very much on the scripting of PiVPN and TTN-Zuerichs Install routine
#============================================================================================================

# Sourcing the function library
. ./99-functions.sh

# Check if root
is_root || die "You need to be root to run this script."

# Install GIT
apt-get install git --yes || die "GIT installation failed" 1
apt-get install olsrd --yes || die "OLSRD installation failed" 1
apt-get install tcpdump --yes || die "TCPDUMP installation failed" 1
apt-get install mtr-tiny --yes || die "mtr-tiny installation failed" 1
apt-get install ntp --yes || die "ntp installation failed" 1

# Deinstall physical swap
# disable and remove only if package is installed
dpkg -s dphys-swapfile && systemctl disable dphys-swapfile
dpkg -s dphys-swapfile && apt-get purge dphys-swapfile --yes

# Cleanup
apt-get autoremove --yes || die "Cleanup failed" 1

do_reboot

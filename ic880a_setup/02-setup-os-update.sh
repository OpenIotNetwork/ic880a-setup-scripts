#!/bin/bash -e
#title           :04-setup-os-update.sh
#description     :This script updates the raspi.
#author          :cabbage (bernhard@openiot.at)
#usage           :bash 04-setup-packetforwarder.sh
#notes           :This script relies very much on the scripting of PiVPN and TTN-Zuerichs Install routine
#============================================================================================================

# Sourcing the function library
. ./99-functions.sh

# Check if root
is_root || die "You need to be root to run this script."

# Check if SPI is configured
if [ `lsmod | grep -i spi | wc -l` -lt 1 ]
then
        echo "SPI is not configured! Did you reboot after enabling SPI? Exiting."
        exit 1
fi

# Update raspi

apt-get update --yes || die "ERROR: apt-get update failed." 1
apt-get upgrade --yes
apt-get dist-upgrade --yes

do_reboot

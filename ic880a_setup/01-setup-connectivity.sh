#!/bin/bash -e
#title           :01-setup-connectivity.sh
#description     :This script sets up the needed users.
#author          :cabbage (bernhard@openiot.at)
#date            :20190224
#version         :1.0
#usage           :bash 04-setup-packetforwarder.sh
#notes           :This script relies very much on the scripting of PiVPN and TTN-Zuerichs Install routine
#============================================================================================================

# Sourcing the function library
. ./99-functions.sh

# Check if root
is_root || die "You need to be root to run this script."

# Set the right locale
locale=de_AT.UTF-8
layout=de
raspi-config nonint do_change_locale $locale
raspi-config nonint do_configure_keyboard $layout

# Join Wifi network
echo 'network={' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'ssid="wlansid"' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'psk="wlanpassword"' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf

# Start ssh
systemctl enable ssh
systemctl start ssh

# Enable SPI
if [ `cat /boot/config.txt | grep -i spi | grep -v ^# | wc -l` -eq 0 ]
then
	echo "Adding SPI support"
	echo "dtparam=spi=on" >> /boot/config.txt
fi

# Reboot raspi
do_reboot
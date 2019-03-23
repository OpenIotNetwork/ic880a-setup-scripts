#!/bin/bash -e
#title           :04-setup-user.sh
#description     :This script sets up the needed users.
#author          :cabbage (bernhard@openiot.at)
#usage           :bash 04-setup-user.sh
#notes           :This script relies very much on the scripting of PiVPN and TTN-Zuerichs Install routine
#============================================================================================================

# Sourcing the function library
. ./99-functions.sh

# Check if root
is_root || die "You need to be root to run this script."

# Add new user
adduser --disabled-password --gecos "" ttn
adduser ttn sudo

# Add ttn user to sudoers
echo "ttn ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "PASSWORT FÜR TTN USER MUSS HÄNDISCH VERGEBEN WERDEN!"
passwd ttn

userdel -rf pi

do_reboot
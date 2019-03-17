#!/bin/bash -e
#title           :98-check-gw-status.sh
#description     :This script checks the status of the gateway and prints it´s config.
#author          :cabbage (bernhard@openiot.at)
#date            :20190317
#version         :1.0
#usage           :bash 98-check-gw-status.sh
#notes           :This script relies very much on the scripting of PiVPN and TTN-Zuerichs Install routine
#============================================================================================================

# Sourcing the function library
. ./99-functions.sh

# Check if root
is_root || die "You need to be root to run this script."

# print local config
print_local_config

# check gateway status
check_gateway_status
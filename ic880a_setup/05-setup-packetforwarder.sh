#!/bin/bash -e
#title           :04-setup-packetforwarder.sh
#description     :This script installs the packet forwarder and creates its config.
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

# Get first non-loopback network device that is currently connected
GATEWAY_EUI_NIC=$(ip -oneline link show up 2>&1 | grep -v LOOPBACK | sed -E 's/^[0-9]+: ([0-9a-z]+): .*/\1/' | head -1)
if [[ -z $GATEWAY_EUI_NIC ]]; then
    die "No network interface found. Cannot set gateway ID." 1
fi

# Then get EUI based on the MAC address of that device
GATEWAY_EUI=$(cat /sys/class/net/$GATEWAY_EUI_NIC/address | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
GATEWAY_EUI=${GATEWAY_EUI^^} # toupper

echo "Detected EUI $GATEWAY_EUI from $GATEWAY_EUI_NIC"

# get hostname
if NEW_HOSTNAME=$(whiptail --title "Choose A Hostname" --inputbox "Host name [ttn-gateway]:" ${r} ${c} 3>&1 1>&2 2>&3)
then
	if [[ $NEW_HOSTNAME == "" ]]; then NEW_HOSTNAME="ttn-gateway"; fi
else
	die "User aborted dialog."
fi

are_you_sure "Gateway-Infos"

# get gateway name
if GATEWAY_NAME=$(whiptail --title "Choose A Gateway Name" --inputbox "Gateway name [ttn-ic880a]:" ${r} ${c} 3>&1 1>&2 2>&3)
then
	if [[ $GATEWAY_NAME == "" ]]; then GATEWAY_NAME="ttn-ic880a"; fi
else
	die "User aborted dialog." 1
fi

# get email
if GATEWAY_EMAIL=$(whiptail --title "Input your E-Mail" --inputbox "E-Mail [hello@openiot.at]:" ${r} ${c} 3>&1 1>&2 2>&3)
then
	if [[ $GATEWAY_EMAIL == "" ]]; then GATEWAY_EMAIL="hello@openiot.at"; fi
else
	die "User aborted dialog." 1
fi

# get latitude
if GATEWAY_LAT=$(whiptail --title "Choose Gateway Geo-Location." --inputbox "Latitude [0]:" ${r} ${c} 3>&1 1>&2 2>&3)
then
	if [[ $GATEWAY_LAT == "" ]]; then GATEWAY_LAT=0; fi
else
	die "User aborted dialog." 1
fi

# get longitude
if GATEWAY_LON=$(whiptail --title "Choose Gateway Geo-Location" --inputbox "Longitude [0]:" ${r} ${c} 3>&1 1>&2 2>&3)
then
	if [[ $GATEWAY_LON == "" ]]; then GATEWAY_LON=0; fi
else
	die "User aborted dialog." 1
fi

# Altitude

if GATEWAY_ALT=$(whiptail --title "Choose Gateway Geo-Location" --inputbox "Altitude [0]:" ${r} ${c} 3>&1 1>&2 2>&3)
then
	if [[ $GATEWAY_ALT == "" ]]; then GATEWAY_ALT=0; fi
else
	die "User aborted dialog." 1
fi

are_you_sure "Change Hostname"

######################

# Change hostname if needed
CURRENT_HOSTNAME=$(hostname)

if [[ $NEW_HOSTNAME != $CURRENT_HOSTNAME ]]; then
    echo "Updating hostname to '$NEW_HOSTNAME'..."
    hostname $NEW_HOSTNAME
	cp /etc/hostname /etc/hostname.bak
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
fi

are_you_sure "Install packet forwarder"

# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="/opt/ttn-gateway"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

are_you_sure "Build gateway app"

# Build LoRa gateway app
if [ ! -d lora_gateway ]; then
    git clone -b legacy https://github.com/TheThingsNetwork/lora_gateway.git
    pushd lora_gateway
else
    pushd lora_gateway
    git fetch origin
    git checkout legacy
    git reset --hard
fi

sed -i -e 's/PLATFORM= kerlink/PLATFORM= imst_rpi/g' ./libloragw/library.cfg

are_you_sure "Start compiling"

make

popd

are_you_sure "Fetch packet forwarder sources"

# Build packet forwarder
if [ ! -d packet_forwarder ]; then
    git clone -b legacy https://github.com/TheThingsNetwork/packet_forwarder.git
    pushd packet_forwarder
else
    pushd packet_forwarder
    git fetch origin
    git checkout legacy
    git reset --hard
fi

are_you_sure "Start compiling packet forwarder"

make

popd

are_you_sure  "Linking and moving files"

# Symlink poly packet forwarder
if [ ! -d bin ]; then mkdir bin; fi
if [ -f ./bin/poly_pkt_fwd ]; then rm ./bin/poly_pkt_fwd; fi
ln -s $INSTALL_DIR/packet_forwarder/poly_pkt_fwd/poly_pkt_fwd ./bin/poly_pkt_fwd || die "Creating the symlink for poly_pkt_fwd failed" 1 
cp -f ./packet_forwarder/poly_pkt_fwd/global_conf.json ./bin/global_conf.json || die "Copying the global_conf failed" 1

LOCAL_CONFIG_FILE=$INSTALL_DIR/bin/local_conf.json

# Remove old config file
if [ -e $LOCAL_CONFIG_FILE ]; then rm $LOCAL_CONFIG_FILE; fi;

echo -e "{\n\t\"gateway_conf\": {\n\t\t\"gateway_ID\": \"$GATEWAY_EUI\",\n\t\t\"servers\": [ { \"server_address\": \"router.eu.thethings.network\", \"serv_port_up\": 1700, \"serv_port_down\": 1700, \"serv_enabled\": true }, { \"server_address\": \"stats.vie01.openiot.network\", \"serv_port_up\": 1700, \"serv_port_down\": 1700, \"serv_enabled\": true } ],\n\t\t\"ref_latitude\": $GATEWAY_LAT,\n\t\t\"ref_longitude\": $GATEWAY_LON,\n\t\t\"ref_altitude\": $GATEWAY_ALT,\n\t\t\"contact_email\": \"$GATEWAY_EMAIL\",\n\t\t\"description\": \"$GATEWAY_NAME\" \n\t}\n}" >$LOCAL_CONFIG_FILE

popd

echo "Gateway EUI is: $GATEWAY_EUI"
echo "The hostname is: $NEW_HOSTNAME"
echo "Open TTN console and register your gateway using your EUI: https://console.thethingsnetwork.org/gateways"
echo "Installation completed."

# Change the reset PIN to the layout of the adapter platine

CHOICE=$(whiptail --title "What adapter platine are you using?" --radiolist --separate-output "Choose:" 20 78 15 \
        "Standard" "IMST ic880a + normal (small) adapter platine" on \
        "ch2i" "IMST ic880a + ch2i (big) adapter platine" off 3>&1 1>&2 2>&3 )

case $CHOICE in
                Standard)
                        echo "IMST ic880a + normal (small) adapter platine"
                        sed -i s/^.*RESET_BCM_PIN=.*$/SX1301_RESET_BCM_PIN=25/g ./start.sh
                ;;
                ch2i)
                        echo "IMST ic880a + ch2i (big) adapter platine"
                        sed -i s/^.*RESET_BCM_PIN=.*$/SX1301_RESET_BCM_PIN=17/g ./start.sh
                ;;
                *)
                ;;
esac

# Start packet forwarder as a service
cp ./start.sh $INSTALL_DIR/bin/
cp ./ttn-gateway.service /lib/systemd/system/
systemctl enable ttn-gateway.service

do_reboot
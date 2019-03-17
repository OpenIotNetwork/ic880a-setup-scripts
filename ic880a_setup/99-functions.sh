#!/bin/bash -e
#title           :99-functions.sh
#description     :This script contains a set of functions that is used in the other install scripts.
#author          :cabbage (bernhard@openiot.at)
#date            :20190316
#version         :1.1
#usage           :You should not use this script directly. It is automatically sourced (included) in the other scripts.
#notes           :This script contains a set of functions that is used in the other install scripts.
#============================================================================================================

# set variables 
declare -r TRUE=0
declare -r FALSE=1
declare -r PASSWD_FILE=/etc/passwd
declare -r SHADOW_FILE=/etc/shadow
declare -r GW_STATUS_TMPFILE=/tmp/gateway_status.txt

##################################################################
# Purpose: Set the variables for whiptail
# Arguments: this is executed when the files is sourced into the script
##################################################################

# Find the rows and columns. Will default to 80x24 if it can not be detected.
declare -r screen_size=$(stty size 2>/dev/null || echo 24 80)
declare -r rows=$(echo $screen_size | awk '{print $1}')
declare -r columns=$(echo $screen_size | awk '{print $2}')

# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

##################################################################
# Purpose: Display an error message and die
# Arguments:
#   $1 -> Message
#   $2 -> Exit status (optional)
##################################################################
function die() 
{
	local m="[\e[31mERROR\e[0m]: $1"	# message
	local e=${2-1}	# default exit status 1
	echo -e "$m" 
	exit $e
}

##################################################################
# Purpose: Return true if script is executed by the root user
# Arguments: none
# Return: True or False
##################################################################
function is_root() 
{
   [ $(id -u) -eq 0 ] && return $TRUE || return $FALSE
}

##################################################################
# Purpose: Return true $user exits in /etc/passwd
# Arguments: $1 (username) -> Username to check in /etc/passwd
# Return: True or False
##################################################################
function is_user_exits() 
{
	local u="$1"
	grep -q "^${u}" $PASSWD_FILE && return $TRUE || return $FALSE
}

##################################################################
# Purpose: Are-you-sure-you-want-to-go-on safty function 
# Arguments: $1 (text) -> text to display in the message
# Return: True&continue or False&die
##################################################################

function are_you_sure() 
{
	if (whiptail --backtitle "Are you sure you want to go on?" --title "Debug" --yesno "Next step: ${1} - Wanna go on?" ${r} ${c}) then
		echo "OK. Let's rock!"
		return $TRUE
	else
		die "chicken out like a little bitch" $FALSE
	fi
}

##################################################################
# Purpose: do_reboot function 
# Arguments: no arguments
# Return: True&continue or False&die
##################################################################

function do_reboot() 
{
	if (whiptail --backtitle "At this point we suggest a reboot." --title "A reboot is needed." --yesno "Do you want to reboot now?" ${r} ${c}) then
		echo "Reboot in 5 seconds. Press Contro-C to abort."
		sleep 5
		reboot
	else
		echo "Alright. No reboot right now."
		exit 0
	fi
}

##################################################################
# Purpose: Prints the status of the gateway (running/not running)
# Arguments: no arguments
# Return: n/a
##################################################################

function check_gateway_status() 
{
	local RESULT=0
	
	RESULT=`ps -ef | grep /opt/ttn-gateway/bin/start.sh | grep -v grep | wc -l`
	if [ "$RESULT" -lt "1" ] 
	then
		die "There are not enough start.sh scripts running."
	else 
		echo -e "start.sh running......[\e[32mOK\e[0m]"
	fi
	
	RESULT=`ps -ef | grep ./poly_pkt_fwd | grep -v grep | wc -l`
	
	if [ "$RESULT" -lt "1" ] 
	then
		die "There are not enough poly_pkt_fwd processes running."
	else 
		echo -e "poly_pkt_fwd process running......[\e[32mOK\e[0m]"
	fi

	RESULT=`systemctl show -p SubState --value ttn-gateway.service | grep "running" | grep -v grep | wc -l`

	if [ "$RESULT" -lt "1" ]
	then
		die "Systemctl service ttn-gateway.service not active"
	else
		echo -e "Systemctl service ttn-gateway.service is active......[\e[32mOK\e[0m]"
	fi
}

##################################################################
# Purpose: Prints the configured local configuration (from local_conf.json)
# Arguments:
#   $1 -> 1 = print without bash colors (needed for whiptail dialog)
# Return: n/a
##################################################################

function print_local_config() 
{

	local RESULT=0

	# UID
	RESULT=`[ -e /opt/ttn-gateway/bin/local_conf.json ] && cat /opt/ttn-gateway/bin/local_conf.json |sed -e 's/[{}]/''/g' | grep gateway_ID | awk '{ print $2 }' | cut -d'"' -f2`

	if [ -z "$RESULT" ]
	then
		die "Could not extract EUI from json config file."
	else
		[ $1 ] && echo -e "Gateway EUI:\e[1m $RESULT \e[0m" 
		[ ! $1 ] && echo -e "Gateway EUI: $RESULT"
	fi

	#email
	RESULT=`[ -e /opt/ttn-gateway/bin/local_conf.json ] && cat /opt/ttn-gateway/bin/local_conf.json | grep contact | awk '{ print $2 }' | cut -d'"' -f2`
	if [ -z "$RESULT" ]
	then
		die "Could not extract contact-email from config file."
	else
		[ $1 ] && echo -e "Contact-email:\e[1m $RESULT \e[0m" 
		[ ! $1 ] && echo -e "Contact-email: $RESULT"
	fi	
	
	#description  
	RESULT=`[ -e /opt/ttn-gateway/bin/local_conf.json ] && cat /opt/ttn-gateway/bin/local_conf.json | grep description | awk '{ print $2 }' | cut -d'"' -f2`
	if [ -z "$RESULT" ]
	then
		die "Could not extract description from config file."
	else
		[ $1 ] && echo -e "Gateway description:\e[1m $RESULT \e[0m"
		[ ! $1 ] && echo -e "Gateway description: $RESULT"
	fi	
	
	#ref_latitude
	RESULT=`[ -e /opt/ttn-gateway/bin/local_conf.json ] && cat /opt/ttn-gateway/bin/local_conf.json | grep ref_latitude | awk '{ print $2 }' | cut -d'"' -f2 | cut -d',' -f1`
	if [ -z "$RESULT" ]
	then
		die "Could not extract ref_latitude from config file."
	else
		[ $1 ] && echo -e "Gateway latitude:\e[1m $RESULT \e[0m"
		[ ! $1 ] && echo -e "Gateway latitude: $RESULT"  
	fi	
	
	#ref_longitude
	RESULT=`[ -e /opt/ttn-gateway/bin/local_conf.json ] && cat /opt/ttn-gateway/bin/local_conf.json | grep ref_longitude | awk '{ print $2 }' | cut -d'"' -f2 | cut -d',' -f1`
	if [ -z "$RESULT" ]
	then
		die "Could not extract ref_longitude from config file."
	else
		[ $1 ] && echo -e "Gateway Longitude:\e[1m $RESULT \e[0m"
		[ ! $1 ] && echo -e "Gateway Longitude: $RESULT"
	fi	
	
	#ref_altitude
	RESULT=`[ -e /opt/ttn-gateway/bin/local_conf.json ] && cat /opt/ttn-gateway/bin/local_conf.json | grep ref_altitude | awk '{ print $2 }' | cut -d'"' -f2 | cut -d',' -f1`
	if [ -z "$RESULT" ]
	then
		die "Could not extract ref_altitude from config file."
	else
		[ $1 ] && echo -e "Gateway altitude:\e[1m $RESULT \e[0m"
		[ ! $1 ] && echo -e "Gateway altitude: $RESULT"
	fi
}

##################################################################
# Purpose: gateway_status_dialog - show the status of the gateway in a dialog
# Arguments: no arguments
# Return: n/a
##################################################################

function gateway_status_dialog()
{
		print_local_config > ${GW_STATUS_TMPFILE} || die "Couldn't write ${GW_STATUS_TMPFILE}"
		[ -e ${GW_STATUS_TMPFILE} ] || die "Couldn't read ${GW_STATUS_TMPFILE}"
		whiptail --title "Content of the local_conf.json file" --textbox ${GW_STATUS_TMPFILE} ${r} ${c}
		rm ${GW_STATUS_TMPFILE} || die "Couldn't remove ${GW_STATUS_TMPFILE}"
}


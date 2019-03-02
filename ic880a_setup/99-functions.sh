#!/bin/bash -e
# set variables 
declare -r TRUE=0
declare -r FALSE=1
declare -r PASSWD_FILE=/etc/passwd
declare -r SHADOW_FILE=/etc/shadow

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
    local m="ERROR: $1"	# message
    local e=${2-1}	# default exit status 1
    echo "$m" 
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


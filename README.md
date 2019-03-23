# OpenIoT Gateway Installation Scripts

## Purpose ##
The purpose of this project is to support the installation of ic880a based Raspberry Pi TTN gateways for the community OpenIoT.

This has been done for:
* OpenIoT community - https://openiot.network
* TTN Vienna - https://www.thethingsnetwork.org/community/vienna/

## Credits & Thanks to... ##
Thanks to:
* TTN Zurich - They did a great job with their gateway setup tutorial and installation script. As a matter of fact a lot has been copied from their routines. This has two reasons: they did a really great job and we would like to have our gateways being set up from the same baseline.
* PiVPN - They have the best setup routine I've seen so far. Therefore I learned a lot and also copied some code from these guys.

# Documentation #
This documentation should lead you through the installation and setup of your IMST ic880a Raspberry Pi LoRaWAN Gateway.

We created some videos that walk you through the whole procedures (no sound).

Link | Content of the video
--- | ---
https://youtu.be/Z9vN4JBwPyc | Prepare SD card and copy installation scripts to your SD card.
https://youtu.be/JZEnr5Lz1-A | Complete installation procedure Part1 (parts that have to be done on the console)
https://youtu.be/-a2BNTK87_0 | Complete installation procedure Part2 (after the raspery pi been connected to the network)

## Step 1 - Prepare installation ##
The purpose of the preparation is to copy all scripts in this repository to your Raspberry Pi.
One way to do that is to copy the scripts to your SD card, directly after flashing the Raspbian image. This works quite good when using Windows for flashing the Raspi Lite Image to your USB.

### Windows ###
* Download Raspbian Light image from the internet (https://www.raspberrypi.org/downloads/raspbian/)
* Use Win32Imager (https://sourceforge.net/projects/win32diskimager/) to flash the image to your SD card
After the SD-card has been successfully written: 
* Unplug the SD-Card and replug it again. This triggers Windows to mount all partitions on the SD card. Most of them don't work anyway and that´s ok at this point. Most important is, that the /boot partition will be mounted and accessable through your windows explorer.
* Open your Windows Explorer and navigate to the /boot Volume of your SD-card. 
* Create a subdirectory 'ic880a_setup' in the /boot Volume of your SD-card
* Copy the ic880a setup scripts on your SD-Card (into the /boot/ directory).
* Unmount all volumes by using the remove-eject icon (safely remove hardware) (this may not be necessary, but it's good for karma)

You have now created a SD card with raspi-lite containing the ic880a install scripts in the /boot/ic880a_setup directory.

### Additional stuff ###
* Put in your Wifi credentials!
Open the first script "01-setup-connectivity.sh" and put in your Wifi connection details.
This will make it more comfortable during the setup. 

## Step 2 - Install everything! ##
The purpose of this step is to use the prepared scripts to update your raspi, deinstall unneccessary stuff, install important stuff, fetch gateway software, compile it, run it.
To do this you just have to execute the scripts in the prepared order starting with 01_xxx.sh
The last script is called 99-functions.sh and should not be executed explicitly (though it does not do any harm). It contains a set of functions that is used by the other scripts.

### Overview over the whole procedure ###
* Boot your Raspberry Pi
* Login as user 'pi' with password 'raspberry' (attention: there will be an english keyboard layout at the beginning)
* Change to root user (e.g. sudo bash -o vi)
* Copy the scripts from /boot/ic880a_setup to /root/
e.g. cp -r /boot/ic880a_setup /root
* Navigate to your script directory (e.g. /root/ic880a_setup)
* Execute the install scripts from 01-setup-connectivity.sh until 05-setup-packetforwarder.sh.
  * 01-setup-connectivity.sh
  * 02-setup-os-update.sh
  * 03-setup-user.sh
  * 04-install-add-packages.sh
  * 05-setup-packetforwarder.sh
* While doing this you need to reboot the raspi several times as prompted by the dialogues

### 01-setup-connectivity.sh ###
This script is executed when you do not even have a network connection.
It basically sets all the keyboard / locale to a German / Austrian setup.
This script also connects you to your wifi network, if you put in the right credentials.
In the end this script will ask you for a reboot.

This script: 
* Connects you to wifi (please edit the credentials within the script) 
* Sets your locale and keyboard layout to Gemany/Austria

```

pi@raspberrypi:~ $ sudo bash -o vi
root@raspberrypi:/home/pi# cp -r /boot/ic880a_setup /root
root@raspberrypi:/home/pi# cd /root/ic880a_setup
root@raspberrypi:/root/ic880a_setup# 
root@ttn-kaiserallee:~/ic880a_setup# ls -tlar
insgesamt 52
-rwxr-xr-x 1 root root 1259 Nov 13 14:05 01-setup-connectivity.sh
-rwxr-xr-x 1 root root  234 Nov 13 14:05 ttn-gateway.service
-rwxr-xr-x 1 root root 7929 Nov 13 14:05 99-functions.sh
-rwxr-xr-x 1 root root  713 Nov 13 14:05 98-check-gw-status.sh
-rwxr-xr-x 1 root root 6374 Nov 13 14:05 05-setup-packetforwarder.sh
-rwxr-xr-x 1 root root 1113 Nov 13 14:05 04-install-add-packages.sh
-rwxr-xr-x 1 root root  840 Nov 13 14:05 03-setup-user.sh
-rwxr-xr-x 1 root root  881 Nov 13 14:05 02-setup-os-update.sh
drwx------ 3 root root 4096 Nov 13 14:05 ..
-rwxr-xr-x 1 root root  690 Mär 17 14:34 start.sh
drwxr-xr-x 2 root root 4096 Mär 17 14:34 .
root@ttn-kaiserallee:~/ic880a_setup#
root@ttn-kaiserallee:~/ic880a_setup# ./01-setup-connectivity.sh

```

### 02-setup-os-update.sh ###
* After the reboot login as user pi/raspberry
* Change to root user (e.g. sudo bash -o vi)
* **Check if you have connectivity to the network & internet ** (will be automated in further relases)

```

 root@raspberrypi:/home/pi# cd /root
 root@raspberrypi:~# ping 8.8.8.8
 PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
 64 bytes from 8.8.8.8: icmp_seq=1 ttl=53 time=13.6 ms
 64 bytes from 8.8.8.8: icmp_seq=2 ttl=53 time=13.6 ms
 ^C
 --- 8.8.8.8 ping statistics ---
 9 packets transmitted, 9 received, 0% packet loss, time 8014ms
 rtt min/avg/max/mdev = 11.877/13.036/13.696/0.637 ms
 root@raspberrypi:~#
 
```

* Navigate to your script directory (/root/ic880a_setup/)

```

 root@raspberrypi:~# cd /root/ic880a_setup/
 root@raspberrypi:~/ic880a_setup#

```

* Execute 02-setup-connectivity.sh
This script:
* updates your operating system instance
* updates all the packages
* configures SPI functionality

```

 root@raspberrypi:~/ic880a_setup# ./02-setup-os-update.sh
 Holen:1 http://archive.raspberrypi.org/debian stretch InRelease [25,4 kB]
 Holen:2 http://raspbian.raspberrypi.org/raspbian stretch InRelease [15,0 kB]
 Holen:3 http://raspbian.raspberrypi.org/raspbian stretch/main armhf Packages [11,7 MB]
 Holen:4 http://archive.raspberrypi.org/debian stretch/main armhf Packages [214 kB]
 Holen:5 http://archive.raspberrypi.org/debian stretch/ui armhf Packages [44,4 kB]
 Holen:6 http://raspbian.raspberrypi.org/raspbian stretch/non-free armhf Packages [95,5 kB]
 Es wurden 12,1 MB in 10 s geholt (1.165 kB/s).
 Paketlisten werden gelesen... Fertig
 Paketlisten werden gelesen... Fertig
 Abhängigkeitsbaum wird aufgebaut.
 Statusinformationen werden eingelesen.... Fertig
 Paketaktualisierung (Upgrade) wird berechnet... Fertig
 Die folgenden Pakete werden aktualisiert (Upgrade):
   apt apt-transport-https apt-utils base-files bluez-firmware curl gnupg gnupg-agent gpgv libapt-inst2.0
   libapt-pkg5.0 libc-bin libc-dev-bin libc-l10n libc6 libc6-dbg libc6-dev libcurl3 libcurl3-gnutls libpam-systemd
   libperl5.24 libpolkit-agent-1-0 libpolkit-backend-1-0 libpolkit-gobject-1-0 libraspberrypi-bin libraspberrypi-dev
   libraspberrypi-doc libraspberrypi0 libssl1.0.2 libssl1.1 libsystemd0 libudev1 libwbclient0 libxapian30 locales
   multiarch-support openssh-client openssh-server openssh-sftp-server openssl perl perl-base perl-modules-5.24
   policykit-1 python-rpi.gpio python3-six raspberrypi-bootloader raspberrypi-kernel raspberrypi-sys-mods
   raspi-config raspi-copies-and-fills samba-common ssh systemd systemd-sysv tzdata udev wireless-regdb
   wpasupplicant
 59 aktualisiert, 0 neu installiert, 0 zu entfernen und 0 nicht aktualisiert.
 Es müssen 112 MB an Archiven heruntergeladen werden.
 Nach dieser Operation werden 848 kB Plattenplatz zusätzlich benutzt.
 Holen:1 http://archive.raspberrypi.org/debian stretch/main armhf bluez-firmware all 1.2-3+rpt7 [125 kB]
 Holen:15 http://archive.raspberrypi.org/debian stretch/main armhf python-rpi.gpio armhf 0.6.5~stretch-1 [23,5 kB]
 Holen:2 http://ftp.tugraz.at/mirror/raspbian/raspbian stretch/main armhf base-files armhf 9.9+rpi1+deb9u8 [67,5 kB]
 Holen:16 http://archive.raspberrypi.org/debian stretch/ui armhf python3-six all 1.12.0 [13,3 kB]
 Holen:17 http://archive.raspberrypi.org/debian stretch/main armhf raspberrypi-sys-mods armhf 20181127 [10,2 kB]
 Holen:18 http://archive.raspberrypi.org/debian stretch/main armhf raspi-copies-and-fills armhf 0.11 [7.274 B]
 Holen:19 http://archive.raspberrypi.org/debian stretch/main armhf wireless-regdb all 2018.05.09-0~rpt1 [11,8 kB]
 [...]
 Vorbereitung zum Entpacken von .../libperl5.24_5.24.1-3+deb9u5_armhf.deb ...
 Entpacken von libperl5.24:armhf (5.24.1-3+deb9u5) über (5.24.1-3+deb9u4) ...
 Vorbereitung zum Entpacken von .../perl_5.24.1-3+deb9u5_armhf.deb ...
 Entpacken von perl (5.24.1-3+deb9u5) über (5.24.1-3+deb9u4) ...
 Vorbereitung zum Entpacken von .../perl-base_5.24.1-3+deb9u5_armhf.deb ...
 Entpacken von perl-base (5.24.1-3+deb9u5) über (5.24.1-3+deb9u4) ...
 [...]
 At this point we suggest a reboot.
 
                        ┌──────────────────────┤ A reboot is needed. ├───────────────────────┐
                        │                                                                    │
                        │ Do you want to reboot now?                                         │
                        │                                                                    │
                        │                                                                    │
                        │                                                                    │
                        │                                                                    │
                        │                  <Ja>                      <Nein>                  │
                        │                                                                    │
                        └────────────────────────────────────────────────────────────────────┘
 
```

### 03-setup-user.sh ###
Your system is now pretty much up2date.

* After the reboot login as user pi/raspberry. 
* Change to root user (e.g. sudo bash -o vi)
* Navigate to your script directory (/root/ic880a_setup/)
* Execute 03-setup-user.sh
This script:
* deletes standard user pi
* creates a ttn user
* asks you for a ttn user password
* reboots

```

pi@raspberrypi:~ $ sudo bash -o vi
root@raspberrypi:/home/pi# cd /root/ic880a_setup/
root@raspberrypi:~/ic880a_setup# ./03-setup-user.sh
Lege Benutzer »ttn« an ...
Lege neue Gruppe »ttn« (1001) an ...
Lege neuen Benutzer »ttn« (1001) mit Gruppe »ttn« an ...
Erstelle Home-Verzeichnis »/home/ttn« ...
Kopiere Dateien aus »/etc/skel« ...
Füge Benutzer »ttn« der Gruppe »sudo« hinzu ...
Benutzer ttn wird zur Gruppe sudo hinzugefügt.
Fertig.
PASSWORT FÜR TTN USER MUSS HÄNDISCH VERGEBEN WERDEN!
Geben Sie ein neues UNIX-Passwort ein:
Geben Sie das neue UNIX-Passwort erneut ein:
passwd: Passwort erfolgreich geändert
userdel: user pi is currently used by process 519
userdel: pi Mail-Warteschlange (/var/mail/pi) nicht gefunden

                        ┌──────────────────────┤ A reboot is needed. ├───────────────────────┐
                        │                                                                    │
                        │ Do you want to reboot now?                                         │
                        │                                                                    │
                        │                                                                    │
                        │                                                                    │
                        │                                                                    │
                        │                  <Ja>                      <Nein>                  │
                        │                                                                    │
                        └────────────────────────────────────────────────────────────────────┘

root@raspberrypi:~/ic880a_setup#

```

### 04-install-add-packages.sh ###
Now you got rid of the standard 'pi' user and created a user 'ttn' instead.

* After the reboot login as user ttn/your-ttn-user-password. 
* Change to root user (e.g. sudo bash -o vi)
* Navigate to your script directory (/root/ic880a_setup/)
* Execute 04-install-add-packages.sh

This script:
* installs git, olsrd, tcpdump, mtr-tiny, ntp
* disables and removes physical swapfile

```

ttn@raspberrypi:~ $ sudo bash -o vi
root@raspberrypi:~# cd /home/ttn
root@raspberrypi:/home/ttn# cd /root/ic880a_setup/
root@raspberrypi:~/ic880a_setup# ./04-install-add-packages.sh
Paketlisten werden gelesen... Fertig
Abhängigkeitsbaum wird aufgebaut.
Statusinformationen werden eingelesen.... Fertig
The following additional packages will be installed:
  git-man liberror-perl
Vorgeschlagene Pakete:
  git-daemon-run | git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-arch git-cvs git-mediawiki
  git-svn
Die folgenden NEUEN Pakete werden installiert:
  git git-man liberror-perl
0 aktualisiert, 3 neu installiert, 0 zu entfernen und 0 nicht aktualisiert.
Es müssen 4.849 kB an Archiven heruntergeladen werden.
Nach dieser Operation werden 26,4 MB Plattenplatz zusätzlich benutzt.
Holen:1 http://mirror.inode.at/raspbian/raspbian stretch/main armhf liberror-perl all 0.17024-1 [26,9 kB]
Holen:2 http://ftp.tugraz.at/mirror/raspbian/raspbian stretch/main armhf git-man all 1:2.11.0-3+deb9u4 [1.433 kB]
Holen:3 http://ftp.tugraz.at/mirror/raspbian/raspbian stretch/main armhf git armhf 1:2.11.0-3+deb9u4 [3.390 kB]
Es wurden 4.849 kB in 1 s geholt (2.490 kB/s).
Vormals nicht ausgewähltes Paket liberror-perl wird gewählt.
(Lese Datenbank ... 34705 Dateien und Verzeichnisse sind derzeit installiert.)
Vorbereitung zum Entpacken von .../liberror-perl_0.17024-1_all.deb ...
Entpacken von liberror-perl (0.17024-1) ...
Vormals nicht ausgewähltes Paket git-man wird gewählt.
Vorbereitung zum Entpacken von .../git-man_1%3a2.11.0-3+deb9u4_all.deb ...
Entpacken von git-man (1:2.11.0-3+deb9u4) ...

[...]

Executing: /lib/systemd/systemd-sysv-install disable dphys-swapfile
Paketlisten werden gelesen... Fertig
Abhängigkeitsbaum wird aufgebaut.
Statusinformationen werden eingelesen.... Fertig
Das folgende Paket wurde automatisch installiert und wird nicht mehr benötigt:
  dc
Verwenden Sie »sudo apt autoremove«, um es zu entfernen.
Die folgenden Pakete werden ENTFERNT:
  dphys-swapfile*
0 aktualisiert, 0 neu installiert, 1 zu entfernen und 0 nicht aktualisiert.
Nach dieser Operation werden 61,4 kB Plattenplatz freigegeben.
(Lese Datenbank ... 35752 Dateien und Verzeichnisse sind derzeit installiert.)
Entfernen von dphys-swapfile (20100506-3) ...
Trigger für man-db (2.7.6.1-2) werden verarbeitet ...
(Lese Datenbank ... 35738 Dateien und Verzeichnisse sind derzeit installiert.)
Löschen der Konfigurationsdateien von dphys-swapfile (20100506-3) ...
Trigger für systemd (232-25+deb9u9) werden verarbeitet ...

                        ┌──────────────────────┤ A reboot is needed. ├───────────────────────┐
                        │                                                                    │
                        │ Do you want to reboot now?                                         │
                        │                                                                    │
                        │                                                                    │
                        │                  <Ja>                      <Nein>                  │
                        │                                                                    │
                        └────────────────────────────────────────────────────────────────────┘

root@raspberrypi:~/ic880a_setup#

```	

### 05-setup-packetforwarder.sh ###
Now you have all the packages installed that you'll need for compilation and administration. 
This step is all about downloading the current packet-forwarder sources and compiling it.


* After the reboot login as user ttn/your-ttn-user-password. 
* Change to root user (e.g. sudo bash -o vi)
* Navigate to your script directory (/root/ic880a_setup/)
* Execute 05-setup-packetforwarder.sh

During execution of this script you'll be asked to put in the following things:
* New Hostname
* Gateway name
* E-Mail
* Latitude
* Longitude
* Altitude
* Which type of adapter board you're using (to set the reset pin)

This script:
* Generates the EUI
* Asks the user for it´s parameters (see above)
* Downloads sources for packet-forwarder and lora gateway
* Compiles everything
* Generates all the configuration files
* Sets up a service using systemctl
* Starts the packetforwarder
* Reboots

```

ttn@raspberrypi:~ $ sudo bash -o vi
root@raspberrypi:~# cd /home/ttn
root@raspberrypi:/home/ttn# cd /root/ic880a_setup/
root@raspberrypi:~/ic880a_setup# ./05-setup-packetforwarder.sh
Detected EUI B827EBFFFE3B9E52 from eth0
 

                       ┌───────────────────────┤ Choose A Hostname ├────────────────────────┐
                       │ Host name [ttn-gateway]:                                           │
                       │                                                                    │
                       │ ttn-kaiserallee___________________________________________________ │             │                                                                    │
                       │                 <Ok>                     <Abbrechen>               │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘

					   Are you sure you want to go on?


                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Gateway-Infos - Wanna go on?                            │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘




                       ┌─────────────────────┤ Choose A Gateway Name ├──────────────────────┐
                       │ Gateway name [ttn-ic880a]:                                         │
                       │                                                                    │
                       │ tn-kaiserallee____________________________________________________ │
                       │                                                                    │
                       │                 <Ok>                     <Abbrechen>               │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘



                       ┌───────────────────────┤ Input your E-Mail ├────────────────────────┐
                       │ E-Mail [hello@openiot.at]:                                         │
                       │                                                                    │
                       │ bernhard@openiot.at_______________________________________________ │
                       │                                                                    │
                       │                 <Ok>                     <Abbrechen>               │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘

                       ┌──────────────────┤ Choose Gateway Geo-Location. ├──────────────────┐
                       │ Latitude [0]:                                                      │
                       │                                                                    │
                       │ 48.338229_________________________________________________________ │
                       │                                                                    │
                       │                 <Ok>                     <Abbrechen>               │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘

			           ┌──────────────────┤ Choose Gateway Geo-Location. ├──────────────────┐
                       │ Longitude [0]:                                                     │
                       │                                                                    │
                       │ 16.341590_________________________________________________________ │
                       │                                                                    │
                       │                 <Ok>                     <Abbrechen>               │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘



                       ┌──────────────────┤ Choose Gateway Geo-Location ├───────────────────┐
                       │ Altitude [0]:                                                      │
                       │                                                                    │
                       │ 120_______________________________________________________________ │
                       │                                                                    │
                       │                 <Ok>                     <Abbrechen>               │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘


                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Gateway-Infos - Wanna go on?                            │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘


                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Install packet forwarder - Wanna go on?                 │
                       │                                                                    │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘


                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Build gateway app - Wanna go on?                        │
                       │                                                                    │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘

                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Start compiling - Wanna go on?                          │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘

OK. Let's rock!
make all -e -C libloragw
make[1]: Verzeichnis „/opt/ttn-gateway/lora_gateway/libloragw“ wird betreten
*** Checking libloragw library configuration ***
Release version   : 3.1.0
SPI interface     : Linux native SPI driver
*** Configuration seems ok ***
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I.  src/loragw_hal.c -o obj/loragw_hal.o
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I.  src/loragw_gps.c -o obj/loragw_gps.o
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I.  src/loragw_reg.c -o obj/loragw_reg.o
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I.  src/loragw_spi.native.c -o obj/loragw_spi.o
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I.  src/loragw_aux.c -o obj/loragw_aux.o

[...]



                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Fetch packet forwarder sources - Wanna go on?           │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘



                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Start compiling packet forwarder - Wanna go on?         │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘


make all -e -C basic_pkt_fwd
make[1]: Verzeichnis „/opt/ttn-gateway/packet_forwarder/basic_pkt_fwd“ wird betreten
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I. -D VERSION_STRING="\"`cat ../VERSION`\"" -I../../lora_gateway/libloragw/inc src/basic_pkt_fwd.c -o obj/basic_pkt_fwd.o
gcc -c -O2 -Wall -Wextra -std=c99 -Iinc -I. src/parson.c -o obj/parson.o
src/parson.c: In function ‘remove_comments’
[...]


                       ┌─────────────────────────────┤ Debug ├──────────────────────────────┐
                       │                                                                    │
                       │ Next step: Linking and moving files - Wanna go on?                 │
                       │                                                                    │
                       │                  <Ja>                      <Nein>                  │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘


                   ┌──────────────────┤ What adapter platine are you using? ├───────────────────┐
                   │    (*) Standard  IMST ic880a + normal (small) adapter platine              │
                   │    ( ) ch2i      IMST ic880a + ch2i (big) adapter platine                  │
                   │                                                                            │
                   │                                                                            │
                   │                    <Ok>                        <Abbrechen>                 │
                   │                                                                            │
                   └────────────────────────────────────────────────────────────────────────────┘


                       ┌──────────────┤ Content of the local_conf.json file ├───────────────┐
                       │                                                                    │
                       │ Gateway EUI: B827EBFFFE3B9E52                                      │
                       │ Contact-email: bernhard@openiot.at                                 │
                       │ Gateway description:                                               │
                       │ ttn-kaiserallee                                                    │
                       │ Gateway latitude: 48.338229                                        │
                       │ Gateway Longitude: 16.341590                                       │
                       │ Gateway altitude: 120                                              │
                       │                                                                    │
                       │                               <Ok>                                 │
                       │                                                                    │
                       └────────────────────────────────────────────────────────────────────┘
					   
					   
                        ┌──────────────────────┤ A reboot is needed. ├───────────────────────┐
                        │                                                                    │
                        │ Do you want to reboot now?                                         │
                        │                                                                    │
                        │                                                                    │
                        │                  <Ja>                      <Nein>                  │
                        │                                                                    │
                        └────────────────────────────────────────────────────────────────────┘

root@raspberrypi:~/ic880a_setup#
					   
```

### 98-check-gw-status.sh ###
This is the last step of setting up the gateway. The gateway software (packetforwarder) has been installed and boots up automatically. 

This is how you can check if it works:

* After the reboot login as user ttn/your-ttn-user-password. 
* Change to root user (e.g. sudo bash -o vi)
* Navigate to your script directory (/root/ic880a_setup/)
* Execute 98-check-gw-status.sh

This script:
* Prints the configuration from the local_conf.json file
* Checks if the service is running

```
ttn@raspberrypi:~ $ sudo bash -o vi
root@raspberrypi:~# cd /home/ttn
root@raspberrypi:/home/ttn# cd /root/ic880a_setup/
root@ttn-kaiserallee:~/ic880a_setup# ./98-check-gw-status.sh
Gateway EUI: B827EBFFFE3B9E52
Contact-email: bernhard@openiot.at
Gateway description: ttn-kaiserallee
Gateway latitude: 48.338229
Gateway Longitude: 16.341590
Gateway altitude: 120
start.sh running......[OK]
poly_pkt_fwd process running......[OK]
Systemctl service ttn-gateway.service is active......[OK]
root@ttn-kaiserallee:~/ic880a_setup#

```

### Register your gateway ###
You need to register your new Gateway at The Things Network Console: https://console.thethingsnetwork.org.

## List of files & Documentation 

Filename | Purpose | How to use?
--- | --- | ---
01-setup-connectivity.sh | Setup Gateway | Execute once during installation
02-setup-os-update.sh | Setup Gateway | Execute once during installation
03-setup-user.sh | Setup Gateway | Execute once during installation
04-install-add-packages.sh | Setup Gateway | Execute once during installation
05-setup-packetforwarder.sh | Setup Gateway | Execute once during installation
98-check-gw-status.sh | Check the gateway status and print the current configuration | Is automatically used during installation. Can be manually invoked anytime by the user.
99-functions.sh | Function library | Automatically invoked with the other scripts
ttn-gateway.service | Setup Gateway | Automatically used as a template during installation
start.sh | Setup Gateway | Automatically used as a template during installation

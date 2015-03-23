#!/bin/bash

echo "Installing piscreen"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


echo "Checking for IPv6..."
if [ `lsmod | grep -o ^ipv6` ]; then
  echo "IPv6 is already enabled. Good!"
else
  rm /etc/sysctl.d/disableipv6.conf
  modprobe ipv6
  echo "ipv6" >> /etc/modules
fi

echo "Installing dependencies"
apt-get -y install openbox hsetroot x11-xserver-utils unclutter imagemagick chkconfig xinit nodm watchdog fbi xdotool chromium

echo "Creating screen user"
useradd -m screen
usermod -a -G video screen

echo "Installing nodm auto login"
sed -e 's/NODM_ENABLED=.*$/NODM_ENABLED=true/g' -i /etc/default/nodm
sed -e "s/NODM_USER=.*$/NODM_USER=screen/" -i /etc/default/nodm

echo "Enabling Watchdog"
modprobe bcm2708_wdog
cp /etc/modules /etc/modules.bak
sed '$ i\bcm2708_wdog' -i /etc/modules
chkconfig watchdog on
cp /etc/watchdog.conf /etc/watchdog.conf.bak
sed -e 's/#watchdog-device/watchdog-device/g' -i /etc/watchdog.conf
/etc/init.d/watchdog start

echo "Adding piscreen config-file"
cp ./screen/piscreen.example.txt /boot/piscreen.txt
chmod ugo+r /boot/piscreen.txt

echo "Creating openbox autostart"
mkdir /home/screen/.config
mkdir /home/screen/.config/openbox
touch /home/screen/.config/openbox/autostart
if ! grep -qe "^/home/screen/piscreen/autostart &$" "/home/screen/.config/openbox/autostart"; then
	echo "/home/screen/piscreen/autostart &" >> /home/screen/.config/openbox/autostart
fi
chown -R screen /home/screen/.config

echo "Creating .xsession"
cp ./screen/xsession-example /home/screen/.xsession
chown screen /home/screen/.xsession
chmod +x /home/screen/.xsession

echo "Copying piscreen files"
cp -r ./screen/piscreen /home/screen/
chown -R screen /home/screen/piscreen
chmod +x /home/screen/piscreen/start-browser.sh
chmod +x /home/screen/piscreen/autostart

echo "Allowing screen shutdown"
echo "screen ALL=(ALL) NOPASSWD: /sbin/shutdown, /sbin/poweroff, /sbin/reboot" >> /etc/sudoers

# echo "Adding shutdown-menu entries"
# FIXME: add openbox menu.xml with entries for shutdown & restart

# boot image 
# from http://www.edv-huber.com/index.php/problemloesungen/15-custom-splash-screen-for-raspberry-pi-raspbian
echo "Setting boot screen"
cp ./screen/asplashscreen /etc/init.d/
chmod a+x /etc/init.d/asplashscreen
insserv /etc/init.d/asplashscreen

echo "Assuming no errors were encountered, go ahead and restart the pi."

#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

touch /boot/piscreen_running.txt
echo "I am running." > /boot/piscreen_running.txt

#Get the needed network configuration information
IPV4=`ip addr | sed -e's/^.*inet\([^ ]*\)\/.*$/\1/;t;d' | grep -v "127.0.0.1"`
IPV6=`ip addr | sed -e's/^.*inet6\([^ ]*\)\/.*$/\1/;t;d' | grep -v "::1" | tr '\n' ' '`
MAC=`ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | tr -d ':'`

#Set some state variables
CHROME_RUNNING=0
CHROME_PID=0

#Test the network connectivity
TRIES=10
TEST_URL=http://google.com
TIMEOUT=5
wget -q --tries=1 --timeout=$TIMEOUT --spider $TEST_URL
#Until we have an internet connection
until [[ $? -eq 0 ]]; do
	
	#If no connection decincrement the tries down to -1
	if [[ $TRIES -gt -1 ]]; then
		echo "Could not connect to $TEST_URL. $TRIES attempt(s) remaining before launching Chrome."
		let TRIES-=1
	fi
	
	#If we have tried the set number of times launch chrome
	if [ $TRIES -eq "0" ]; then
		chromium --noerrdialogs --disable-translate --disable-sync --incognito --kiosk "no-internet-connection.html" &>/dev/null &
		CHROME_PID=$!
		CHROME_RUNNING=1
	fi

	#Check the internet connection
	wget -q --tries=1 --timeout=$TIMEOUT --spider $TEST_URL
done

echo "Done testing connection"

#If Chrome was started, kill it
if [ $CHROME_RUNNING -eq 1 ]; then
	kill $CHROME_PID
fi

#Determine the URL to open
URL_TO_OPEN=""
#If the script is running in the wrong directory or if the config file does not exist
if [ ! -e /boot/piscreen.txt ]; then
	URL_TO_OPEN="no-config-file.html"
fi

if [ -e /boot/piscreen.txt ]; then
	#Read the config out of the file
	while read propline ; do
		#ignore comment lines
		echo "$propline" | grep "^#" > /dev/null 2>&1 && continue

		#if not empty, set the property using declare
		[ ! -z "$propline" ] && declare $propline
	done < /boot/piscreen.txt
	
	#If the url is not set in the config
	if [ -z "$url" ]; then
		URL_TO_OPEN="no-url-in-config.html"
	else
		URL_TO_OPEN="$url?mac=$MAC"	
	fi
fi

#Start Chome with our determined URL
chromium --noerrdialogs --disable-translate --disable-sync --incognito --kiosk "$URL_TO_OPEN" &> /dev/null &

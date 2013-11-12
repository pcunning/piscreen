#!/bin/bash

echo "piscreen: start browser"
cd "$( dirname "${BASH_SOURCE[0]}" )"

HOSTNAME=`hostname`
IPV4=`ip addr | sed -e's/^.*inet \([^ ]*\)\/.*$/\1/;t;d' | grep -v "127.0.0.1"`
IPV6=`ip addr | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | grep -v "::1" | tr '\n' ' '`
MAC=`ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | tr -d ':'`

HAS_NETWORK_CONNECTIVITY=0
HAS_INTERNET_CONNECTIVITY=0
if [ -n "$IPV4" ] || [ -n "$IPV6" ]; then
  HAS_NETWORK_CONNECTIVITY=1
fi

TRIES=10
until [ $TRIES -eq 0 ] || [ "$HAS_INTERNET_CONNECTIVITY" -eq "1" ]; do
  curl google.com > /dev/null
  if [ "$?" -eq 0 ]; then
    HAS_INTERNET_CONNECTIVITY=1
  else
      let TRIES-=1
      echo Internet Tries Remaining: $TRIES
      sleep 10
  fi
done

echo "IPv4: $IPV4"
echo "IPv6: $IPV6"
echo "MAC: $MAC"
echo "NET: $HAS_NETWORK_CONNECTIVITY"
echo "WWW: $HAS_INTERNET_CONNECTIVITY"

# todo: create wallpaper, write connection details, set wallpaper

URLTOOPEN=""
if [ "$HAS_NETWORK_CONNECTIVITY" -eq "0" ]; then
  URLTOOPEN="no-network-connection.html"
fi
if [ -z "$URLTOOPEN" ] && [ "$HAS_INTERNET_CONNECTIVITY" -eq "0" ]; then
  URLTOOPEN="no-internet-connection.html"
fi
if [ -z "$URLTOOPEN" ]; then
  if [ ! mountpoint -q /boot ] || [ ! -e /boot/piscreen.txt ]; then
    URLTOOPEN="no-config-file.html"
  fi
fi
if [ -e /boot/piscreen.txt ]; then
  while read propline ; do
    # ignore comment lines
    echo "$propline" | grep "^#" >/dev/null 2>&1 && continue
    # if not empty, set the property using declare
    [ ! -z "$propline" ] && declare $propline
  done < /boot/piscreen.txt

  if [ -z "$URLTOOPEN" ]; then
    if [ -z "$url" ]; then
      URLTOOPEN="no-url-in-config.html"
    else
      URLTOOPEN="$url?ipv4=$IPV4&ipv6=$IPV6"
    fi
  fi
fi

echo "Starting Chrome..."
echo "URL: $URLTOOPEN"

# using --incognito for ignoring session restore after a power loss
chrome --noerrdialogs --disable-translate --disable-sync --incognito --kiosk "$URLTOOPEN" &
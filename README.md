# About piscreen

*piscreen* is a small, Chromium based, Kiosk/Digital Signage solution for the [Raspberry Pi](http://raspberrypi.org).


The difference to other signage-software like [Screeny OSE](https://github.com/wireload/screenly-ose) is that it supports just one static URL that it displays - but it provides nice error screens when your network/the internet is not reachable.

# Installation
## 1. Preparing the SD card

1. Get the latest [Rasbpian](http://www.raspberrypi.org/downloads/) for your Raspberry Pi and write it to the SD card with dd (on Linux & Mac):

        dd bs=1M if=raspbian.img of=/dev/sdX

  You can also write to the SD card with [Win32DiskImager](https://wiki.ubuntu.com/Win32DiskImager) if you are using Windows. 

2. Insert the SD in the Raspberry Pi and power it on

## 2. Basic (manual) Updating & Configuration

1. Log in as *pi* with the Password: *raspberry*. If the password doesn't work look in the [Pi FAQ](http://www.raspberrypi.org/help/quick-start-guide/).

2. A basic auto-configuration tool should appear (if not, start `raspi-config`). 
  
  Set your keyboard-layout, timezone, overscan-settings (if you see black borders on your screen), overclock (tip: use Medium) and resize the root partition. A reboot should happen. After the resizing login again.

3. Update the System

        apt-get update
        apt-get -y dist-upgrade

  If a conflict happens for any file press `Y`.

4. Reboot the Pi: `reboot`

## 3. Setup the automatic installation

1. Login again as *pi*.

2. Run the automatic installer: `wget https://raw.githubusercontent.com/ZaneMiller/piscreen/master/install.sh && sudo bash ./install.sh [default url]` *NOTE:* You must replace `[default url]` with the url the display should launch to.

3. After the installation is complete check to make sure there were no errors. If you wish to add a splash screen add the image to `/etc/splash.png`.

4. Assuming no errors occured you may restart the Pi.

## 4. Test and run

Insert the SD card back into the Raspberry Pi and power it on. It should now boot, open chrome in fullscreen with your desired URL.

To shutdown it nicely, press `ALT+F4`, rightclick, choose *Terminal* and enter `sudo poweroff`.

# Todo

* Read the hostname from `piscreen.txt` and set it on boot.
* Support proxies
* Add nicer shutdown button

# Thanks

[Screeny OSE](https://github.com/wireload/screenly-ose) and the [Raspberry Pi forums](http://www.raspberrypi.org/forum) for the inspiration.

[hexxeh](http://hexxeh.net) for the [RPi Binaries of Chromium](http://hexxeh.net/?p=328117859).

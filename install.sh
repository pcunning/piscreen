#!/bin/bash

if [ -z "$1" ]; then
	echo "You must provide a url for this display"
	exit 0
fi

#install the git core
echo "Installing the git core."
apt-get install -y git-core

#clone the project directory
echo "Pulling the project directory"
git clone https://github.com/pcunning/piscreen.git ./screen

#configure the example script
echo "Configuring the display url"
sed -e "s/url=.*$/url=$1" -i ./screen/piscreen.example.txt

#run the setup
echo "Running setup"
./screen/setup.sh

#remove the cloned directory
echo "Cleaning up"
rm -f -R screen

echo "Done!"
echo "You may add a startup image at /boot/splash.png"
echo "If there were no errors, restart the pi to complete the setup."

#!/bin/bash

mount -o remount,rw /
mount -o remount,rw /boot

echo "backup original files..."
cp /usr/local/bin/MMDVMCal /usr/local/bin/MMDVMCal_origin
cp /usr/local/bin/MMDVMHost /usr/local/bin/MMDVMHost_origin
cp /usr/local/bin/RemoteCommand /usr/local/bin/RemoteCommand_origin
echo "------------"

echo "Stop MMDVM service..."
systemctl stop mmdvmhost.timer
systemctl stop mmdvmhost.service
echo "------------"

echo "Downloading new MMDVMHost files..."
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/MMDVM/MMDVMCal" -o /usr/local/bin/MMDVMCal
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/MMDVM/MMDVMHost" -o /usr/local/bin/MMDVMHost
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/MMDVM/RemoteCommand" -o /usr/local/bin/RemoteCommand
echo "------------"
echo " "
echo "Done!"
echo " "

/bin/sync
/bin/sync
/bin/sync
mount -o remount,ro /
mount -o remount,ro /boot

echo "Please Reboot Pi-Star!"
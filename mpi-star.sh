#!/bin/bash

# Load RRD tool for Ping Server

if [[ -f /var/www/dashboard/ping_wan_hour.png ]]
then
  exit 0
else
  curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/rrd_setup.sh | bash
fi


pistarCurVersion=$(awk -F "= " '/Version/ {print $2}' /etc/pistar-release)
if [[ ${pistarCurVersion} == "4.1.4" ]]
  then
  pistarHardware=$(awk -F "= " '/Hardware/ {print $2}' /etc/pistar-release)
  if [[ ${pistarHardware} == "OrangePiZero" ]]
  then
    curl -s -o /usr/local/sbin/pistar-upgrade https://raw.githubusercontent.com/AndyTaylorTweet/Pi-Star_Binaries_sbin/master/pistar-upgrade
    pistar-upgrade
  else
    exit 0  
  fi
fi
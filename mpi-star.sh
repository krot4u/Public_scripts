#!/bin/bash

# Load RRD tool for Ping Server

if [[ -f /var/www/dashboard/ping_wan_hour.png ]]
then
  echo "done"
else
  curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/rrd_setup.sh | bash
fi

date1_ts=$(date -d $(date +%F) +%s)
date2_ts=$(date -d "2023-04-28" +%s)

if [ "$date1_ts" -gt "$date2_ts" ]
  then
    echo "done"
else
  curl --fail -s -o "/var/rrds/ping/ping.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping.sh
  curl --fail -s -o "/var/rrds/ping/ping-graph.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping-graph.sh
fi

#
# ---------- Update pistar-upgrade file
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
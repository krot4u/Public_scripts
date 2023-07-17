#!/bin/bash
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

curl --fail -o '/usr/local/sbin/pistar-watchdog' -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-watchdog
curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-update > '/usr/local/sbin/pistar-update'
#!/bin/bash

mount -o remount,rw /
mount -o remount,rw /boot

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

CHECK_WATCHDOG=$(grep 'P25Gateway' /usr/local/sbin/pistar-watchdog >/dev/null; echo $?)
if [[ $CHECK_WATCHDOG -gt 0 ]]; then
  echo "All Good!"
  exit 0
else
  curl --fail -o '/usr/local/sbin/pistar-watchdog' -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-watchdog
  curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-update > '/usr/local/sbin/pistar-update'
fi

echo "Fix SelfOnly"
sed -i -E '/^\[DMR\]$/,/^\[/ s/^SelfOnly=0/SelfOnly=1/' "/etc/mmdvmhost"

curl --fail -s -o "/var/rrds/ping/ping.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping.sh

sed -i '/^\[DMR Network 4\]/,/^$/d' /etc/dmrgateway
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
  cat <<EOF >> /etc/dmrgateway
[DMR Network 4]
Enabled=1
Address=freedmr.qra-team.online
Port=62031
Password=QraDMRfree
PassAllPC0=1
PassAllPC1=2
Debug=0
Id=${DMRID}
Location=0
Name=QRAlink
EOF
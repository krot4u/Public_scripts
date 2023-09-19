#!/bin/bash

mount -o remount,rw /
mount -o remount,rw /boot

## -------- Fix DMR SelfOnly (Private HotSpot)
DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
if [ ${DMRID} != 2500621 && ${DMRID} != 7700850 && ${DMRID} != 5973501 ]
  echo "Fix SelfOnly"
  sed -i -E '/^\[DMR\]$/,/^\[/ s/^SelfOnly=0/SelfOnly=1/' "/etc/mmdvmhost"
fi

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
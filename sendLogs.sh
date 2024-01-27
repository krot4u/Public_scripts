#!/bin/bash
rpi-rw
data=$(date +"%Y-%m-%d")
logs=$(ls /var/log/pi-star/*-$data.log)
callsign=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
tar="/tmp/$callsign-logs-$data.tar.gz"
token=$1

mount -o remount,rw /

tar -czvf $tar $logs 2> /dev/null

curl \
  -H "Authorization: Bearer $token" \
  -F "file=@$tar" \
  "http://monitor.qra-team.online:8080/upload"

/bin/sync
/bin/sync
/bin/sync
mount -o remount,ro /
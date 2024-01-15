#!/bin/bash
data=$(date +"%Y-%m-%d")
logs=$(ls /var/log/pi-star/*-$data.log)
callsign=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
tar="/tmp/$callsign-logs-$data.tar.gz"
token=$1

tar -czvf $tar $logs 2> /dev/null

curl \
  -H "Authorization: Bearer $token" \
  -F "file=@$tar" \
  "http://monitor.qra-team.online:8080/upload"
#!/bin/bash
export LC_ALL=C
logs=$(ls /var/log/pi-star/*-$(date +"%Y-%m-%d").log)
callsign=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
tar="/tmp/$callsign-logs-$(date +"%Y-%m-%d").tar.gz"
token=$1

tar -czvf $tar $logs 2> /dev/null

curl \
  -F "file=@./$tar" \
  -F "token=$token" \
  "http://monitor.qra-team.online:8080/upload"

#!/bin/bash
export LC_ALL=C
logs=$(ls /var/log/pi-star/*-$(date +"%Y-%m-%d").log)
callsign=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
token=$1

tar -czvf $callsign-logs-$(date +"%Y-%m-%d").tar.gz- $logs 2> /dev/null

curl \
  -F "file=@$callsign-logs.tar.gz" \
  "http://monitor.qra-team.online:8080"

#!/bin/bash
export LC_ALL=C
logs=$(ls /var/log/pi-star/*-$(date +"%Y-%m-%d").log)
callsign=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
token=$1

tar -czvf $callsign-logs.tar.gz $logs 2> /dev/null

curl -Ffile=@$callsign-logs.tar.gz \
  -F "token=$token" \
  http://localhost:25478/upload
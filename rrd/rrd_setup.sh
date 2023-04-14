#!/bin/bash

echo "RPI-RW..."
mount -o remount,rw / ; mount -o remount,rw /boot
echo "------------"

echo "deb http://mirrordirector.raspbian.org/raspbian/ oldstable main contrib non-free rpi" > /etc/apt/sources.list.d/oldstable.list

apt-get update > /dev/null
apt-get install rrdtool gawk -y > /dev/null

curl --fail -s -o "/var/rrds/ping/ping.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping.sh
curl --fail -s -o "/var/rrds/ping/ping-graph.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping-graph.sh
curl --fail -s -o "/var/www/dashboard/ping.php" https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/ping.php
chmod +x /var/rrds/ping/ping.sh
chmod +x /var/rrds/ping/ping-graph.sh

if [[ ! -d "/var/rrds/ping" ]]
then
    mkdir -p /var/rrds/ping
    /usr/bin/rrdtool create /var/rrds/ping/ping_wan.rrd \
    --step 60 \
    DS:pl:GAUGE:600:0:100 \
    DS:rtt:GAUGE:600:0:10000000 \
    RRA:AVERAGE:0.5:1:800 \
    RRA:AVERAGE:0.5:6:800 \
    RRA:AVERAGE:0.5:24:800 \
    RRA:AVERAGE:0.5:288:800 \
    RRA:MAX:0.5:1:800 \
    RRA:MAX:0.5:6:800 \
    RRA:MAX:0.5:24:800 \
    RRA:MAX:0.5:288:800
fi

crontab -l > /tmp/cronjob
checkpresent=`cat /tmp/cronjob | grep 'ping.sh'`

if [ -z "$checkpresent" ]
  then
    echo "* * * * *  /var/rrds/ping/ping.sh" >> /tmp/cronjob
    echo "1,6,11,16,21,26,31,36,41,46,51,56 * * * *  /var/rrds/ping/ping-graph.sh" >> /tmp/cronjob
    crontab /tmp/cronjob
  else
    exit 0
  fi

rm -f /tmp/cronjob

touch /usr/local/sbin/.rrdtool

echo "RPI-RO..."
/bin/sync
/bin/sync
/bin/sync
mount -o remount,ro /
mount -o remount,ro /boot
echo "------------"

#!/bin/bash
rpi-rw

apt install rrdtool gawk -y > /dev/null

curl --fail -s -o "/var/rrds/ping/ping.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping.sh
curl --fail -s -o "/var/rrds/ping/ping-graph.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping-graph.sh
chmod +x /var/rrds/ping/ping.sh
chmod +x /var/rrds/ping/ping-graph.sh

mkdir -p /var/rrds/ping
/usr/bin/rrdtool create /var/rrds/ping/ping_wan.rrd \
--step 300 \
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

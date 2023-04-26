#!/bin/bash

mount -o remount,rw /
mount -o remount,rw /boot

PING=/bin/ping
COUNT=4
DEADLINE=10

ping_host() {
    local output=$($PING -q -n -c $COUNT -w $DEADLINE $1 2>&1)
    # notice $output is quoted to preserve newlines
    local temp=$(echo "$output"| awk '
        BEGIN           {pl=100; rtt=0.1}
        /packets transmitted/   {
            match($0, /([0-9]+)% packet loss/, matchstr)
            pl=matchstr[1]
        }
        /^rtt/          {
            # looking for something like 0.562/0.566/0.571/0.024
            match($4, /(.*)\/(.*)\/(.*)\/(.*)/, a)
            rtt=a[2]
        }
        /unknown host/  {
            # no output at all means network is probably down
            pl=100
            rtt=0.1
        }
        END             {print pl ":" rtt}
        ')
    RETURN_VALUE=$temp
}

ping_host qra-team.online

/usr/bin/rrdtool update \
    /var/rrds/ping/ping_wan.rrd \
    --template \
    pl:rtt \
    N:$RETURN_VALUE

mount -o remount,ro /
mount -o remount,ro /boot
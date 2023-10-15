#!/bin/bash

# mount -o remount,rw /
# mount -o remount,rw /boot

## -------- Fix DMR SelfOnly (Private HotSpot) --------- ##
# DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
# if [[ ${DMRID} != 2500621 && ${DMRID} != 7700850 && ${DMRID} != 5973501 && ${DMRID} != 2120212 && ${DMRID} != 1000001]]; then
#   echo "Fix SelfOnly"
#   sed -i -E '/^\[DMR\]$/,/^\[/ s/^SelfOnly=0/SelfOnly=1/' "/etc/mmdvmhost"
# fi

## -------- Fix Ping Server --------- ##
curl --fail -s -o "/var/rrds/ping/ping.sh" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/ping.sh

sudo crontab -l > /tmp/cronjob
oldstring="\10 \* \* \* \*  \/var\/rrds\/ping\/ping\.sh"
newstring="\*\/5 \* \* \* \*  \/var\/rrds\/ping\/ping\.sh"
sed -i -e "s@$oldstring@$newstring@" /tmp/cronjob

# sudo crontab /tmp/cronjob

## -------- Add HBlink for Private Calls --------- ##
#sed -i '/^\[DMR Network 4\]/,/^$/d' /etc/dmrgateway
# sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
# DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
#   cat <<EOF >> /etc/dmrgateway

# [DMR Network 4]
# Enabled=1
# Address=hbl.qra-team.online
# Port=62031
# Password=QraDMRfree
# TGRewrite0=2,9990,2,9990,1
# PassAllPC0=1
# PassAllPC1=2
# Debug=0
# Id=${DMRID}
# Location=0
# Name=QRAlink
# EOF

## --------- Fix Phantom TX --------- ##
# echo "Configuring INI files"
# sed -i -E '/^\[DMR Network\]$/,/^\[/ s/^Jitter=1000/Jitter=250/' "/etc/mmdvmhost"
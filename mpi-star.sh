#!/bin/bash

mount -o remount,rw /

## -------- Get Fresh HostFilesUpdate --------- ##
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

## -------- Set Crontab--------- ##
# m h   dom     mon     dow     command
ENABLECRON="
5973757
6102504
4200042
5973272
5973011
5002012
6201488
2500620
5000540
4852001
8600001
6660444
6660555
6660777
6660888
6660999
"

DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway | tr -d '\r')
if echo "${ENABLECRON}" | grep -q "${DMRID}"; then
  echo "Set Reboot by Cron for ${DMRID}"
  crontab -l > /tmp/crontab.tmp
  if ! $(cat /tmp/crontab.tmp | grep -q "shutdown"); then
    echo "0 3 * * * /sbin/shutdown -r +20" >> /tmp/crontab.tmp
    crontab /tmp/crontab.tmp
    rm -f /tmp/crontab.tmp
  fi
else
  echo "Nothing to do. Skip Cron"
fi

## -------- Fix DMR SelfOnly (Private HotSpot) --------- ##
# DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
# if [[ ${DMRID} != 2500621 && ${DMRID} != 7700850 && ${DMRID} != 5973501 && ${DMRID} != 2120212 && ${DMRID} != 1000001]]; then
#   echo "Fix SelfOnly"
#   sed -i -E '/^\[DMR\]$/,/^\[/ s/^SelfOnly=0/SelfOnly=1/' "/etc/mmdvmhost"
# fi

## --------- Add Test Network --------- ##
# TESTING="
# 7800555
# 5973272
# 4852001
# 5973842
# 5973757
# 9200015
# 4200042
# 2500782
# "
# DMRID=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/mmdvmhost)
# if echo ${TESTING} | grep -q ${DMRID}; then
#   sed -i '/^\[DMR Network 3\]/,/^$/d' /etc/dmrgateway
#   sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
#     cat <<EOF >> /etc/dmrgateway

# [DMR Network 3]
# Enabled=1
# Name=QRA-Test
# Id=${DMRID}
# Address=hbl.qra-team.online
# Port=62033
# Password=SomeTest38876
# TGRewrite0=2,597301,2,597301,1
# TGRewrite1=2,597302,2,597302,1
# TGRewrite2=2,597303,2,597303,1
# TGRewrite3=2,9999,2,9999,1
# PassAllPC0=1
# PassAllPC1=2
# Debug=0
# Location=0
# EOF
# else
#   echo "Do nothing!"
# fi

## --------- Fix Phantom TX --------- ##

## -------- Send Statistic --------- ##
# CALLSIGN=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
# DMRID=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/mmdvmhost)
# LOCALIPS=$(hostname -I)
# curl -d "{
#   \"CALLSIGN\": \"$CALLSIGN\",
#   \"DMRID\": \"$DMRID\",
#   \"LOCALIPS\": \"$LOCALIPS\"
# }" -H "Content-Type: application/json" https://eo93ugfkclu0yv4.m.pipedream.net > /dev/null

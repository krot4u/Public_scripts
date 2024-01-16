#!/bin/bash

mount -o remount,rw /
mount -o remount,rw /boot


# m h   dom     mon     dow     command

DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
if [[ ${DMRID} == 5973757 ]]; then
  echo "Set Reboot by Cron"
  crontab -l > /tmp/crontab.tmp
  echo "20 3 * * * root reboot" >> /tmp/crontab.tmp
  crontab /tmp/crontab.tmp
fi

## -------- Get Fresh HostFilesUpdate --------- ##
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh
curl --fail -o /usr/local/sbin/pistar-firewall -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-firewall
curl --fail -o /usr/local/sbin/pistar-update -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-update
curl --fail -o /usr/local/sbin/pistar-upgrade -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-upgrade
curl --fail -o /usr/local/sbin/pistar-watchdog -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-watchdog

## -------- Fix DMR SelfOnly (Private HotSpot) --------- ##
# DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
# if [[ ${DMRID} != 2500621 && ${DMRID} != 7700850 && ${DMRID} != 5973501 && ${DMRID} != 2120212 && ${DMRID} != 1000001]]; then
#   echo "Fix SelfOnly"
#   sed -i -E '/^\[DMR\]$/,/^\[/ s/^SelfOnly=0/SelfOnly=1/' "/etc/mmdvmhost"
# fi

## -------- Add HBlink for Private Calls --------- ##
Exclude="
6660555
1128888
6556181
"
DMRID=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/mmdvmhost)
if echo ${EXCLUDE} | grep -q ${DMRID}; then
  echo "Clean excluded"
  sed -i '/^\[DMR Network 4\]/,/^$/d' /etc/dmrgateway
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
else
  echo "Apply config QRA-hblink"
  sed -i '/\[DMR Network 3\]/,/\[DMR Network 4\]/d' /etc/dmrgateway
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
    cat <<EOF >> /etc/dmrgateway

[DMR Network 3]
Enabled=1
Name=QRA-Private
Id=${DMRID}
Address=hbl.qra-team.online
Port=62033
Password=SomeTest38876
TGRewrite0=2,597301,2,597301,1
TGRewrite1=2,597302,2,597302,1
TGRewrite2=2,597303,2,597303,1
TGRewrite3=2,9999,2,9999,1
PassAllPC0=1
PassAllPC1=2
Debug=0
Location=0
EOF
fi

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
CALLSIGN=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Callsign=/{print $2}' /etc/mmdvmhost)
DMRID=$(awk -F'=' '/\[General\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/mmdvmhost)
LOCALIPS=$(hostname -I)
curl -d "{
  \"CALLSIGN\": \"$CALLSIGN\",
  \"DMRID\": \"$DMRID\",
  \"LOCALIPS\": \"$LOCALIPS\"
}" -H "Content-Type: application/json" https://eo93ugfkclu0yv4.m.pipedream.net > /dev/null

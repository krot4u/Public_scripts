#!/bin/bash

mount -o remount,rw /
mount -o remount,rw /boot

## -------- Fix DMR SelfOnly (Private HotSpot) --------- ##
# DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
# if [[ ${DMRID} != 2500621 && ${DMRID} != 7700850 && ${DMRID} != 5973501 && ${DMRID} != 2120212 && ${DMRID} != 1000001]]; then
#   echo "Fix SelfOnly"
#   sed -i -E '/^\[DMR\]$/,/^\[/ s/^SelfOnly=0/SelfOnly=1/' "/etc/mmdvmhost"
# fi

## -------- Add HBlink for Private Calls --------- ##
Exclude="
2500621
7700850
5973501
2120212
1000001
6660555
1128888
6660888
6660444
5973757
5973842
5973272
7800555
4852001
"
DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
if echo ${Exclude} | grep ${DMRID}; then
  echo "Do nothing!"
else
  echo "Apply config QRA-hblink"
  sed -i '/^\[DMR Network 4\]/,/^$/d' /etc/dmrgateway
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
  DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
    cat <<EOF >> /etc/dmrgateway

[DMR Network 4]
Enabled=1
Name=QRA-hblink
Id=${DMRID}
Address=hbl.qra-team.online
Port=62030
Password=QraDMRfree
TGRewrite0=2,597301,2,597301,1
TGRewrite1=2,597302,2,597302,1
TGRewrite2=2,9990,2,9990,1
PassAllPC0=1
PassAllPC1=2
Debug=0
Location=0
EOF
fi

## --------- Add firewall with ports 62032 62033 --------- ##
if cat /usr/local/sbin/pistar-firewall | grep -q '62033 -j ACCEPT'; then
  echo "Do nothing!"
else
  curl --fail -o /usr/local/sbin/pistar-firewall -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-firewall
  /usr/local/sbin/pistar-firewall > /dev/null
fi

## --------- Add new DMR network for Surgut Voyager --------- ##

if [[ ${DMRID} == "5973757" || ${DMRID} == "5973842" || ${DMRID} == "4852001" || ${DMRID} == "5973272" || ${DMRID} == "7800555" ]]; then
  echo "Apply config Port 62033"
  sed -i '/^\[DMR Network 4\]/,/^$/d' /etc/dmrgateway
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' /etc/dmrgateway # remove empty line in the end
  DMRID=$(awk -F'=' '/\[XLX Network\]/{a=1; next} /\[/{a=0} a && /Id=/{print $2}' /etc/dmrgateway)
    cat <<EOF >> /etc/dmrgateway

[DMR Network 4]
Enabled=1
Name=QRA-hblink
Id=${DMRID}
Address=hbl.qra-team.online
Port=62033
Password=QraDMRfree
TGRewrite0=2,597302,2,597302,1
PassAllPC0=1
PassAllPC1=2
Debug=0
Location=0
EOF
else
  echo "Do nothing!"
fi

## --------- Fix Phantom TX --------- ##
# echo "Configuring INI files"
# sed -i -E '/^\[DMR Network\]$/,/^\[/ s/^Jitter=1000/Jitter=250/' "/etc/mmdvmhost"

## --------- Fix pistar-watchdog --------- ##
echo "Apply config enable ysf2dmr"
curl --fail -o /usr/local/sbin/pistar-watchdog -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-watchdog
systemctl enable ysfgateway.service > /dev/null
systemctl enable ysf2dmr.service > /dev/null
systemctl enable ysfgateway.timer > /dev/null
systemctl enable ysf2dmr.timer > /dev/null
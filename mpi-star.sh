#!/bin/bash
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/index.php" > '/var/www/dashboard/index.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/index.php" > '/var/www/dashboard/admin/index.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/expert/index.php" > '/var/www/dashboard/admin/expert/index.php'

#IP=$(curl -s http://ipinfo.io/ip)
#ORG=$(curl -s http://ipinfo.io/org)
#CITY=$(curl -s http://ipinfo.io/city)
#DEVICES=$(arp -a | awk '{print $1}' | grep -v '?')
#MESSAGE="<b>IP:</b> ${IP}\n<b>CITY:</b> ${CITY}\n<b>PROVIDER:</b> ${ORG}\n<b>DEVICES:</b> ${DEVICES}"

#curl -X POST https://api.telegram.org/bot$tgtoken/sendMessage -d chat_id=$tgchatid -d parse_mode=html -d text="$(echo -e $MESSAGE)"

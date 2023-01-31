#!/bin/bash
set -e
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

if [ "$(id -u)" != "0" ];then
        echo "This script must be run as root" 1>&2
        exit 1
fi

read -p "Введите Ваш DMRID (7 цифр): " DMRID
if [[ ( $DMRID != ^[[:digit:]]+$ ) && ( $(`echo ${DMRID} |awk '{print length}'`) -ne 7 ) ]];then
	echo " "
	echo -e "   ${RED}Ошибка: Неправильный DMR ID!${NC}" 1>&2
	echo " "
	exit 1
else
	echo "----->"
	echo -e "   ${GRN}Ваш DMRID ${DMRID} ${NC}"
	echo "----->"
	echo " "
fi

echo "Введите частоту приёма\передачи. Задаётся без разделителя"
read -p "(6 символов. Пример:433500): " FREQUENCY
echo ""
if [[ ( $FREQUENCY != ^[[:digit:]]+$ ) && ( $(`echo ${FREQUENCY} |awk '{print length}'`) -ne 6 ) ]];then
	echo " "
	echo -e "   ${RED}Ошибка: Неверная частота!${NC}" 1>&2
	echo " "
	exit 1
else
	echo "----->"
	echo -e "   ${GRN}Частота приёма\передачи ${FREQUENCY} ${NC}"
	echo "----->"
	echo " "
	FREQUENCY="${FREQUENCY}000"
fi

read -p "Введите Ваш позывной ( <= 7 символов): " CALLSIGN
echo ""
if [[ ( $CALLSIGN != ^[[:alnum:]]+$ ) && ( $(`echo ${CALLSIGN} |awk '{print length}'`) -gt 7 ) ]];then
	echo " "
	echo -e "   ${RED}Ошибка: Неправильный позывной!${NC}" 1>&2
	echo " "
	exit 1
else
	echo "----->"
	echo -e "   ${GRN}Ваш позывной ${CALLSIGN} ${NC}"
	echo "----->"
	echo " "
fi

echo "${CALLSIGN} -- ${FREQUENCY} -- ${DMRID}"

service_handle() {
	# What do we want do to?
	doWhat=${1}

	systemctl ${doWhat} pistar-watchdog.service 2> /dev/null 2>&1
	systemctl ${doWhat} pistar-remote.service 2> /dev/null 2>&1
	systemctl ${doWhat} dmrgateway.service 2> /dev/null 2>&1
	systemctl ${doWhat} dapnetgateway.service 2> /dev/null 2>&1
	systemctl ${doWhat} ircddbgateway.service 2> /dev/null 2>&1
	systemctl ${doWhat} timeserver.service 2> /dev/null 2>&1
	systemctl ${doWhat} ysfgateway.service 2> /dev/null 2>&1
	systemctl ${doWhat} ysf2dmr.service 2> /dev/null 2>&1
	systemctl ${doWhat} ysf2nxdn.service 2> /dev/null 2>&1
	systemctl ${doWhat} ysf2p25.service 2> /dev/null 2>&1
	systemctl ${doWhat} ysfparrot.service 2> /dev/null 2>&1
	systemctl ${doWhat} dmr2ysf.service 2> /dev/null 2>&1
	systemctl ${doWhat} dmr2nxdn.service 2> /dev/null 2>&1
	systemctl ${doWhat} p25gateway.service 2> /dev/null 2>&1
	systemctl ${doWhat} p25parrot.service 2> /dev/null 2>&1
	systemctl ${doWhat} nxdngateway.service 2> /dev/null 2>&1
	systemctl ${doWhat} nxdnparrot.service 2> /dev/null 2>&1
	systemctl ${doWhat} dstarrepeater.service 2> /dev/null 2>&1
	systemctl ${doWhat} mmdvmhost.service && sleep 3 > /dev/null 2>&1
}

echo "Downloading modified HostFilesUpdate.sh..."
curl -H 'Cache-Control: no-cache, no-store' --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

echo "Stopping Services..."
service_handle stop
echo "Done"
echo "------------"
/bin/bash /usr/local/sbin/HostFilesUpdate.sh > /dev/null 2>&1

echo "Backup /etc/dmrgateway and /etc/mmdvmhost"
cp /etc/dmrgateway /etc/dmrgateway.$(date +%Y%m%d)
cp /etc/mmdvmhost /etc/mmdvmhost.$(date +%Y%m%d)
echo "Removing /etc/dmrgateway and /etc/mmdvmhost"
rm -f /etc/dmrgateway
rm -f /etc/mmdvmhost

echo "Downloading modified dmrgateway and mmdvmhost..."
curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/dmrgateway -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrgateway.ini
curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/mmdvmhost -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mmdvmhost.ini
echo "Done"
echo "------------"
echo "Updating dmrgateway and mmdvmhost..."
sed -i "s/--Frequency--/$FREQUENCY/" /etc/dmrgateway
sed -i "s/--DMRID--/$DMRID/" /etc/dmrgateway

sed -i "s/--CALLSIGN--/$CALLSIGN/" /etc/mmdvmhost
sed -i "s/--DMRID--/$DMRID/" /etc/mmdvmhost
sed -i "s/--Frequency--/$FREQUENCY/" /etc/mmdvmhost
echo "Done"
echo "------------"
echo "Run pi-star update..."
/usr/local/sbin/pistar-update
echo "------------"
echo "Done! Exiting..."
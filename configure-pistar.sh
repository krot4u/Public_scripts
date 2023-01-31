#!/bin/bash

RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

if [ "$(id -u)" != "0" ];then
        echo "Ошибка! Необходимо выполнить ${GRN}sudo su - ${NC}" 1>&2
        exit 1
fi

mount -o remount,rw / ; mount -o remount,rw /boot

read_dmrid() {
	while true; do
		read -p "Введите Ваш DMRID (7 цифр): " DMRID
		len=`echo ${DMRID} |awk '{print length}'`
		if [[ ( ${DMRID} != ^[[:digit:]]+$ ) && ( $len -ne 7 ) ]];then
			echo "----->"
			echo -e "   ${RED}Ошибка: Неправильный DMRID!${NC}" 1>&2
			echo "----->"
			echo " "
		else
			echo "----->"
			echo -e "   ${GRN}Ваш DMRID ${DMRID} ${NC}"
			echo "----->"
			echo " "
			break
		fi
	done
}

read_frequency() {
	while true; do
		echo "Введите частоту приёма\передачи. Задаётся без разделителя"
		read -p "(6 символов. Пример:433500): " FREQUENCY
		len=`echo ${FREQUENCY} |awk '{print length}'`
		if [[ ( ${FREQUENCY} != ^[[:digit:]]+$ ) && ( $len -ne 6 ) ]];then
			echo "----->"
			echo -e "   ${RED}Ошибка: Неверная частота!${NC}" 1>&2
			echo "----->"
			echo " "
		else
			echo "----->"
			echo -e "   ${GRN}Частота приёма\передачи ${FREQUENCY} ${NC}"
			echo "----->"
			echo " "
			FREQUENCY="${FREQUENCY}000"
			break
		fi
	done
}

service_handle() {
	# What do we want do to?
	doWhat=${1}

	systemctl ${doWhat} pistar-watchdog.service 2> /dev/null
	systemctl ${doWhat} dmrgateway.service 2> /dev/null
	systemctl ${doWhat} timeserver.service 2> /dev/null
	systemctl ${doWhat} mmdvmhost.service 2> /dev/null && sleep 3 > /dev/null 2>&1
}

read_dmrid </dev/tty
read_frequency </dev/tty

echo "Downloading modified pistar-updateh..."
curl -H 'Cache-Control: no-cache, no-store' --fail -o /usr/local/sbin/pistar-update -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

echo "Downloading modified HostFilesUpdate.sh..."
curl -H 'Cache-Control: no-cache, no-store' --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

echo "Stopping Services..."
service_handle stop
echo "Done"
echo "------------"
/bin/bash /usr/local/sbin/HostFilesUpdate.sh > /dev/null 2>&1

CALLSIGN=$(grep $DMRID /usr/local/etc/DMRIds.dat | awk '{print $2}')

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

exit 0
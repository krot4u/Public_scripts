#!/bin/bash

RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

if [ "$(id -u)" != "0" ];then
        echo "This script must be run as root" 1>&2
        exit 1
fi

sudo mount -o remount,rw / ; sudo mount -o remount,rw /boot

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

read_callsign() {
	while true; do
		read -p "Введите Ваш позывной ( <= 7 символов): " CALLSIGN
		len=`echo ${CALLSIGN} |awk '{print length}'`
		if [[ ( ${CALLSIGN} != ^[[:alnum:]]+$ ) && ( $len -gt 7 ) ]];then
			echo "----->"
			echo -e "   ${RED}Ошибка: Неправильный Позывной!${NC}" 1>&2
			echo "----->"
			echo " "
		else
			echo "----->"
			echo -e "   ${GRN}Ваш Позывной ${CALLSIGN} ${NC}"
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

	sudo systemctl ${doWhat} pistar-watchdog.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} pistar-remote.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} dmrgateway.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} dapnetgateway.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} ircddbgateway.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} timeserver.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} ysfgateway.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} ysf2dmr.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} ysf2nxdn.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} ysf2p25.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} ysfparrot.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} dmr2ysf.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} dmr2nxdn.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} p25gateway.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} p25parrot.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} nxdngateway.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} nxdnparrot.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} dstarrepeater.service 2> /dev/null 2>&1
	sudo systemctl ${doWhat} mmdvmhost.service && sleep 3 > /dev/null 2>&1
}

read_dmrid </dev/tty
read_callsign </dev/tty
read_frequency </dev/tty

echo "Downloading modified HostFilesUpdate.sh..."
sudo curl -H 'Cache-Control: no-cache, no-store' --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

echo "Stopping Services..."
service_handle stop
echo "Done"
echo "------------"
sudo /bin/bash /usr/local/sbin/HostFilesUpdate.sh > /dev/null 2>&1

echo "Backup /etc/dmrgateway and /etc/mmdvmhost"
sudo cp /etc/dmrgateway /etc/dmrgateway.$(date +%Y%m%d)
sudo cp /etc/mmdvmhost /etc/mmdvmhost.$(date +%Y%m%d)
echo "Removing /etc/dmrgateway and /etc/mmdvmhost"
sudo rm -f /etc/dmrgateway
sudo rm -f /etc/mmdvmhost

echo "Downloading modified dmrgateway and mmdvmhost..."
sudo curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/dmrgateway -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrgateway.ini
sudo curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/mmdvmhost -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mmdvmhost.ini
echo "Done"
echo "------------"
echo "Updating dmrgateway and mmdvmhost..."
sudo sed -i "s/--Frequency--/$FREQUENCY/" /etc/dmrgateway
sudo sed -i "s/--DMRID--/$DMRID/" /etc/dmrgateway

sudo sed -i "s/--CALLSIGN--/$CALLSIGN/" /etc/mmdvmhost
sudo sed -i "s/--DMRID--/$DMRID/" /etc/mmdvmhost
sudo sed -i "s/--Frequency--/$FREQUENCY/" /etc/mmdvmhost
echo "Done"
echo "------------"
echo "Run pi-star update..."
sudo /usr/local/sbin/pistar-update
echo "------------"
echo "Done! Exiting..."

exit 0
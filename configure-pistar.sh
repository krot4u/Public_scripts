#!/bin/bash

RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"
dmrgateway=/etc/dmrgateway
mmdvmhost=/etc/mmdvmhost

if [ "$(id -u)" != "0" ];then
        echo "Ошибка! Необходимо выполнить ${GRN}sudo su - ${NC}" 1>&2
        exit 1
fi

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
		echo "Введите частоту приёма\передачи на ХотСпоте. Задаётся без разделителя"
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

			A=${FREQUENCY:0:3}
			B=${FREQUENCY:3:3}
			MFREQUENCY="${A}.${B}.000"

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
	systemctl ${doWhat} mmdvmhost.service 2> /dev/null && sleep 3 > /dev/null
}

read_dmrid </dev/tty
read_frequency </dev/tty

echo "Run pi-star upgrade..."
/usr/local/sbin/pistar-upgrade
echo "------------"

echo "RPI-RW..."
mount -o remount,rw / ; mount -o remount,rw /boot
echo "------------"

echo "Downloading modified pistar-updateh..."
curl --fail -o /usr/local/sbin/pistar-update -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-update
echo "------------"

echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh
echo "------------"

echo "Stopping Services..."
service_handle stop
echo "------------"

echo "RUN modified HostFilesUpdate.sh..."
/bin/bash /usr/local/sbin/HostFilesUpdate.sh > /dev/null 2>&1

CALLSIGN=$(grep $DMRID /usr/local/etc/DMRIds.dat | awk '{print $2}')
echo "------------"

echo "Backup /etc/dmrgateway and /etc/mmdvmhost"
cp "${dmrgateway}" "${dmrgateway}.$(date +%Y%m%d)"
cp "${mmdvmhost}" "${mmdvmhost}.$(date +%Y%m%d)"

echo "Clean backup of /etc/dmrgateway and /etc/mmdvmhost"
FILEBACKUP=1
FILES="
${dmrgateway}
${mmdvmhost}"

for file in ${FILES}
do
  BACKUPCOUNT=$(ls ${file}.* | wc -l)
  BACKUPSTODELETE=$(expr ${BACKUPCOUNT} - ${FILEBACKUP})
  if [ ${BACKUPCOUNT} -gt ${FILEBACKUP} ]; then
        for f in $(ls -tr ${file}.* | head -${BACKUPSTODELETE})
        do
                rm $f
        done
  fi
done
echo "------------"

echo "Downloading modified dmrgateway and mmdvmhost..."
curl -H 'Cache-Control: no-cache, no-store' --fail -o "${dmrgateway}" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrgateway.ini
curl -H 'Cache-Control: no-cache, no-store' --fail -o "${mmdvmhost}" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mmdvmhost.ini
curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/dstar-radio.mmdvmhost -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dstar-radio.mmdvmhost
curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/dstarrepeater -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dstarrepeater
curl -H 'Cache-Control: no-cache, no-store' --fail -o /etc/pistar-css.ini -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-css.ini
echo "------------"

echo "Updating dstarrepeater..."
sed -i "s/--CALLSIGN--/$CALLSIGN/" /etc/dstarrepeater
sed -i "s/--Frequency--/$FREQUENCY/" /etc/dstarrepeater

echo "Restart Nginx..."
systemctl restart nginx.service > /dev/null 2>&1
echo "------------"

echo "Updating dmrgateway and mmdvmhost..."
sed -i "s/--Frequency--/$FREQUENCY/" "${dmrgateway}"
sed -i "s/--DMRID--/$DMRID/" "${dmrgateway}"

sed -i "s/--CALLSIGN--/$CALLSIGN/" "${mmdvmhost}"
sed -i "s/--DMRID--/$DMRID/" "${mmdvmhost}"
sed -i "s/--Frequency--/$FREQUENCY/" "${mmdvmhost}"
echo "------------"

echo "Run pi-star update..."
/usr/local/sbin/pistar-update
echo "------------"

echo "Update Web configuration..."
curl -s -u "pi-star:raspberry" \
-o /dev/null \
-H "application/x-www-form-urlencoded" \
-X POST http://127.0.0.1/admin/configure.php \
-d "controllerSoft=MMDVM&trxMode=SIMPLEX&MMDVMModeDMR=OFF&MMDVMModeDSTAR=OFF&MMDVMModeFUSION=OFF&MMDVMModeP25=OFF&MMDVMModeNXDN=OFF&MMDVMModeYSF2DMR=OFF&MMDVMModeYSF2NXDN=OFF&MMDVMModeYSF2P25=OFF&MMDVMModeDMR2YSF=OFF&MMDVMModeDMR2NXDN=OFF&MMDVMModePOCSAG=OFF&MMDVMModeDMR=ON&dmrRfHangTime=2&dmrNetHangTime=2&dstarRfHangTime=2&dstarNetHangTime=2&ysfRfHangTime=2&ysfNetHangTime=2&p25RfHangTime=2&p25NetHangTime=2&nxdnRfHangTime=2&nxdnNetHangTime=2&mmdvmDisplayType=OLED3&mmdvmDisplayPort=&mmdvmNextionDisplayType=ON7LDSL3&APRSGatewayEnable=OFF&confHostame=pi-star&confCallsign=${CALLSIGN}&dmrId=${DMRID}&confFREQ=${MFREQUENCY}&confLatitude=50.00&confLongitude=-3.00&confDesc1=Town%2C+L0C4T0R&confDesc2=Country&confURL=http%3A%2F%2Fwww.mw0mwz.co.uk%2Fpi-star%2F&urlAuto=man&confHardware=stm32dvm&nodeMode=pub&confDMRWhiteList=&selectedAPRSHost=euro.aprs2.net&systemTimezone=Europe%2FMoscow&dashboardLanguage=english_uk&dmrEmbeddedLCOnly=OFF&dmrDumpTAData=OFF&dmrGatewayXlxEn=OFF&dmrGatewayNet1En=OFF&dmrGatewayNet2En=OFF&dmrDMRnetJitterBufer=OFF&dmrMasterHost=127.0.0.1%2Cnone%2C62031%2CDMRGateway&dmrMasterHost1=44.148.230.201%2Cpassw0rd%2C62031%2CBM_2001_Europe_HAMNET&bmHSSecurity=&bmExtendedId=None&dmrMasterHost2=43.245.72.66%2CPASSWORD%2C55555%2CDMR%2B_IPSC2-Australia&dmrNetworkOptions=&dmrPlusExtendedId=None&dmrMasterHost3=46.17.42.12%2Cpassw0rd%2C62030%2CXLX_496&dmrMasterHost3StartupModule=A&dmrGatewayXlxEn=ON&dmrColorCode=1&mobilegps_enable=OFF&mobilegps_port=ttyACM0&mobilegps_speed=38400&dashAccess=PRV&ircRCAccess=PRV&sshAccess=PRV&autoAP=ON&uPNP=ON"

echo "---------- >>>>>>>>>> Обновление завершено... <<<<<<<<<< ----------"
echo " "
echo "---------- >>>>>>>>>> Добро Пожаловать в QRA-Team! <<<<<<<<<< ----------"

exit 0
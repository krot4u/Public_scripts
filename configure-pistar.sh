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
		read -p "(9 цифр. Пример:433.500.000): " MFREQUENCY
		len=`echo ${MFREQUENCY} |awk '{print length}'`
		if [[ ( ${MFREQUENCY} != ^[[:digit:].[:digit:].[:digit:]]+$ ) && ( $len -ne 11 ) ]];then
			echo "----->"
			echo -e "   ${RED}Ошибка: Неверная частота!${NC}" 1>&2
			echo "----->"
			echo " "
		else
			echo "----->"
			echo -e "   ${GRN}Частота приёма\передачи ${MFREQUENCY} ${NC}"
			echo "----->"
			echo " "
			FREQUENCY=${MFREQUENCY//./}
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

echo "Run pi-star Upgrade..."
/usr/local/sbin/pistar-upgrade
echo "------------"

echo "RPI-RW..."
mount -o remount,rw /
mount -o remount,rw /boot
echo "------------"

curl --fail -o /opt/apt-upgrade-keys-add.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/apt-upgrade-keys-add.sh
sudo chmod +x /opt/apt-upgrade-keys-add.sh
sudo /opt/apt-upgrade-keys-add.sh
apt-get upgrade -y

echo "Downloading modified pistar-update..."
curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-update > '/usr/local/sbin/pistar-update'
echo "------------"

echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh > '/usr/local/sbin/HostFilesUpdate.sh'
echo "------------"

echo "Stopping Services..."
service_handle stop
echo "------------"

echo "RUN modified HostFilesUpdate.sh..."
sudo /usr/local/sbin/HostFilesUpdate.sh

CALLSIGN=$(grep $DMRID /usr/local/etc/DMRIds.dat | awk '{print $2}')
echo "------------"

echo "Backup /etc/dmrgateway and /etc/mmdvmhost"
cp "${dmrgateway}" "${dmrgateway}.$(date +%Y%m%d)"
cp "${mmdvmhost}" "${mmdvmhost}.$(date +%Y%m%d)"

echo "Downloading modified dmrgateway and mmdvmhost..."
curl --fail -o "${dmrgateway}" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrgateway.ini
curl --fail -o "${mmdvmhost}" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mmdvmhost.ini
curl --fail -o /etc/dstar-radio.mmdvmhost -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dstar-radio.mmdvmhost
curl --fail -o /etc/dstarrepeater -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dstarrepeater
curl --fail -o /etc/pistar-css.ini -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-css.ini
echo "------------"

echo "RRDtool setup"
curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/rrd_setup.sh | bash
echo "------------"

echo "Updating dstarrepeater..."
sed -i "s/--CALLSIGN--/$CALLSIGN/" /etc/dstarrepeater
sed -i "s/--Frequency--/$FREQUENCY/" /etc/dstarrepeater

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

echo "RPI-RW..."
mount -o remount,rw /
mount -o remount,rw /boot
echo "------------"

echo "Update Web configuration..."
curl -s -u "pi-star:raspberry" \
-o /dev/null \
-H "application/x-www-form-urlencoded" \
-X POST http://127.0.0.1/admin/configure.php \
-d "controllerSoft=MMDVM&trxMode=SIMPLEX&MMDVMModeDMR=OFF&MMDVMModeDSTAR=OFF&MMDVMModeFUSION=OFF&MMDVMModeP25=OFF&MMDVMModeNXDN=OFF&MMDVMModeYSF2DMR=OFF&MMDVMModeYSF2NXDN=OFF&MMDVMModeYSF2P25=OFF&MMDVMModeDMR2YSF=OFF&MMDVMModeDMR2NXDN=OFF&MMDVMModePOCSAG=OFF&MMDVMModeDMR=ON&dmrRfHangTime=2&dmrNetHangTime=2&dstarRfHangTime=2&dstarNetHangTime=2&ysfRfHangTime=2&ysfNetHangTime=2&p25RfHangTime=2&p25NetHangTime=2&nxdnRfHangTime=2&nxdnNetHangTime=2&mmdvmDisplayType=OLED3&mmdvmDisplayPort=&mmdvmNextionDisplayType=ON7LDSL3&APRSGatewayEnable=OFF&confHostame=pi-star&confCallsign=${CALLSIGN}&dmrId=${DMRID}&confFREQ=${MFREQUENCY}&confLatitude=50.00&confLongitude=-3.00&confDesc1=Town%2C+L0C4T0R&confDesc2=Country&confURL=http%3A%2F%2Fwww.mw0mwz.co.uk%2Fpi-star%2F&urlAuto=man&confHardware=stm32dvm&nodeMode=pub&confDMRWhiteList=&selectedAPRSHost=euro.aprs2.net&systemTimezone=Europe%2FMoscow&dashboardLanguage=english_uk&dmrEmbeddedLCOnly=OFF&dmrDumpTAData=OFF&dmrGatewayXlxEn=OFF&dmrGatewayNet1En=OFF&dmrGatewayNet2En=OFF&dmrDMRnetJitterBufer=OFF&dmrMasterHost=127.0.0.1%2Cnone%2C62031%2CDMRGateway&dmrMasterHost1=44.148.230.201%2Cpassw0rd%2C62031%2CBM_2001_Europe_HAMNET&bmHSSecurity=&bmExtendedId=None&dmrMasterHost2=43.245.72.66%2CPASSWORD%2C55555%2CDMR%2B_IPSC2-Australia&dmrNetworkOptions=&dmrPlusExtendedId=None&dmrMasterHost3=46.17.42.12%2Cpassw0rd%2C62030%2CXLX_496&dmrMasterHost3StartupModule=A&dmrGatewayXlxEn=ON&dmrColorCode=1&mobilegps_enable=OFF&mobilegps_port=ttyACM0&mobilegps_speed=38400&dashAccess=PRV&ircRCAccess=PRV&sshAccess=PRV&autoAP=ON&uPNP=ON"
echo " "
echo " "
echo " "
echo -e "${GRN}------------>  Обновление завершено...${NC}"
echo " "
echo -e "${GRN}------------>  Добро Пожаловать в QRA-Team!${NC}"
echo " "
echo " "

exit 0

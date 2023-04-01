#!/bin/bash
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

dmrgateway=/etc/dmrgateway

echo "Set rpi-rw"
mount -o remount,rw / ; mount -o remount,rw /boot

echo "Configuring Hosts files"
echo "496;46.17.42.12;4001" >> ~/XLXHosts.txt
echo "XLX_496	0000	46.17.42.12	passw0rd	62030" >> ~/DMR_Hosts.txt
echo "------------"

echo "Configuring INI files"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Startup=.*/Startup=496/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Enabled=.*/Enabled=1/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Port=.*/Port=62030/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Password=.*/Password=passw0rd/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Slot=.*/Slot=2/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^TG=.*/TG=9/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Base=.*/Base=94000/' "${dmrgateway}"
sed -i -E '/^\[XLX Network\]$/,/^\[/ s/^Module=.*/Module=A/' "${dmrgateway}"
echo "------------"

dmridqra=`cat /usr/local/sbin/HostFilesUpdate.sh | grep 'krot4u/Public_scripts/master/DMRIds.dat'`
if [ ! -z "$dmridqra" ]
  then
    sed -i '/DMRIds.dat --user-agent "Pi-Star_${pistarCurVersion}"/a curl --fail -o /usr/local/etc/DMRIdsQRA.dat -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMRIds.dat' /usr/local/sbin/HostFilesUpdate.sh
    sed -i '/curl --fail -o \/usr\/local\/etc\/DMRIdsQRA.dat -s https:\/\/raw.githubusercontent.com\/krot4u\/Public_scripts\/master\/DMRIds.dat/a cat \/usr\/local\/etc\/DMRIdsQRA.dat >> \/usr\/local\/etc\/DMRIds.dat' /usr/local/sbin/HostFilesUpdate.sh
else
  exit 0
fi

echo "Running pistar-update"
pistar-update
echo "------------"

echo -e "${GRN}------------>  Обновление завершено...${NC}"
echo " "
echo -e "${GRN}------------>  Добро Пожаловать в QRA-Team!${NC}"

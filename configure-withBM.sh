#!/bin/bash
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

dmrgateway=/etc/dmrgateway

echo "Set rpi-rw"
mount -o remount,rw / ; mount -o remount,rw /boot

if [[ "" == $(grep "p25.qra-team.online" /usr/local/etc/P25HostsLocal.txt) ]]
  then
    echo "Configuring P25HostsLocal"
    echo "1	p25.qra-team.online	41000" >> /usr/local/etc/P25HostsLocal.txt
fi

  if [[ "" == $(grep -s "46.17.42.12" /root/XLXHosts.txt) ]]
    then
      echo "Configuring XLXHosts"
      echo "496;46.17.42.12;4001" >> /root/XLXHosts.txt
  else echo -e "${RED} Вы уже подключены в QRA\nЭтот скрипт необходимо запускать на чистом Pi-Star\nИли на Pi-Star не подключенный к QRA ${NC}"
    exit 1
  fi

if [[ "" == $(grep -s "46.17.42.12" /root/DMR_Hosts.txt) ]]
  then
    echo "Configuring DMR_Hosts files"
    echo "XLX_496       0000    46.17.42.12     passw0rd        62030" >> /root/DMR_Hosts.txt
fi
echo "------------"

curl --fail -o /opt/apt-upgrade-keys-add.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/apt-upgrade-keys-add.sh
sudo chmod +x /opt/apt-upgrade-keys-add.sh
sudo /opt/apt-upgrade-keys-add.sh

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

catxlx=`cat /usr/local/sbin/HostFilesUpdate.sh | grep 'cat /root/XLXHosts.txt >> ${XLXHOSTS}'`
if [ -z "$catxlx" ]
  then
  sed -i '/# Add custom YSF Hosts/i if [ -f \"/root/XLXHosts.txt\" ]; then\n      cat /root/XLXHosts.txt >> ${XLXHOSTS}\nfi' /usr/local/sbin/HostFilesUpdate.sh
fi 

dmridqra=$(grep 'krot4u/Public_scripts/master/DMRIds.dat' /usr/local/sbin/HostFilesUpdate.sh)

if [ -z "$dmridqra" ]; then
  sed -i "/DMRIds.dat --user-agent \"Pi-Star_\${pistarCurVersion}\"/a curl --fail -o /usr/local/etc/DMRIdsQRA.dat -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMRIds.dat" /usr/local/sbin/HostFilesUpdate.sh
  sed -i "/curl --fail -o \/usr\/local\/etc\/DMRIdsQRA.dat -s https:\/\/raw.githubusercontent.com\/krot4u\/Public_scripts\/master\/DMRIds.dat/a cat \/usr\/local\/etc\/DMRIdsQRA.dat >> \/usr\/local\/etc\/DMRIds.dat" /usr/local/sbin/HostFilesUpdate.sh
fi

checkAlterPistar=$(grep -s SimplexLogic /etc/svxlink/svxlink.conf)
if [[ "" == $(grep -s SimplexLogic /etc/svxlink/svxlink.conf) ]]; then
  echo "Running pistar-update"
  pistar-update
else
  echo "This is AlterPiStar"
  /usr/local/sbin/HostFilesUpdate.sh
  systemctl restart dmrgateway.service
  systemctl restart mmdvmhost.service
fi

echo " "
echo -e "${GRN}------------>  Обновление завершено...${NC}"
echo " "
echo -e "${GRN}------------>  Добро Пожаловать в QRA-Team!${NC}"
exit 0
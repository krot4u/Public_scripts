#!/bin/bash
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

dmrgateway=/etc/dmrgateway

echo "Set rpi-rw"
mount -o remount,rw / ; mount -o remount,rw /boot

if echo /root/XLXHosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure XLXHosts"
  echo "496;38.180.66.135;4001" >> /root/XLXHosts.txt
fi

if echo /root/P25Hosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure P25Hosts"
  echo "1	p25.qra-team.online	41000" >> /root/P25Hosts.txt
fi

if echo /root/DMR_Hosts.txt | grep -q "38.180.66.135"; then
  echo "Skip!"
else
  echo "------- Configure DMR_Hosts"
  echo "XLX_496       0000    38.180.66.135     passw0rd        62030" >> /root/DMR_Hosts.txt
fi

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
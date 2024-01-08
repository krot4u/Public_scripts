#!/bin/bash
#
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

echo "Set rpi-rw"
mount -o remount,rw / ; mount -o remount,rw /boot


if [ "$(id -u)" != "0" ]; then
    echo -e "You need to be root to run this command...\n"
exit 1
fi

exec 200>/var/lock/qra-hostfiles.lock || exit 1 # only one exec per time
if ! flock -n 200 ; then
    echo "Process already running"
  exit 1
fi

echo -e "${BULL} Stopping WPSD Services. Please wait..."
pkill .wpsd-slipstream-tasks > /dev/null 2>&1
wpsd-services fullstop > /dev/null 2>&1
process_log_file > /dev/null 2>&1
echo -e "  ${TICK} Done!\n"

# Files and locations
DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
P25HOSTS=/usr/local/etc/P25HostsLocal.txt
YSFHOSTS=/usr/local/etc/YSFHosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt
TGLISTP25=/usr/local/etc/TGList_P25.txt
TGLISTYSF=/usr/local/etc/TGList_YSF.txt
RADIOIDDB_TMP=/tmp/user.csv
RADIOIDDB=/usr/local/etc/user.csv
GROUPSTXT=/usr/local/etc/groups.txt
GROUPSNEXTION=/usr/local/etc/groupsNextion.txt
STRIPPED=/usr/local/etc/stripped.csv
COUNTRIES=/usr/local/etc/country.csv
dmrgateway=/etc/dmrgateway
hostFileURL="http://qra.ru/"
uaStr="QRA Updater Ver 0.1"


# Add DMR Files
if [ ! -f "/root/DMR_Hosts.txt" ]; then
	touch /root/DMR_Hosts.txt
fi


# Add P25 Files
if [ ! -f "/root/P25Hosts.txt" ]; then
	touch /root/P25Hosts.txt
fi

# Add XLX Files
if [ ! -f "/root/XLXHosts.txt" ]; then
	touch /root/XLXHosts.txt
fi

# Add YSF Files
if [ ! -f "/root/YSFHosts.txt" ]; then
	touch /root/YSFHosts.txt
fi


if grep '38.180.66.135' /root/XLXHosts.txt  ; then 
  echo "Skip!"
else
  echo "------- Configure XLXHosts"
  echo "496;38.180.66.135;4001" >> /root/XLXHosts.txt
fi


if grep 'p25.qra-team.online' /root/P25Hosts.txt  ; then 
  echo "Skip!"
else
  echo "------- Configure P25Hosts"
  echo "1	p25.qra-team.online	41000" >> /root/P25Hosts.txt
fi

if grep '38.180.66.135' /root/DMR_Hosts.txt  ; then 
  echo "Skip!"
else
  echo "------- Configure DMR_Hosts"
  echo "XLX_496       0000    38.180.66.135     passw0rd        62030" >> /root/DMR_Hosts.txt
fi


if grep '38.180.66.135' /root/YSFHosts.txt  ; then 
  echo "Skip!"
else
  echo "------- Configure YSFHosts"
  echo "00496;XLX496;XLX-QRA;38.180.66.135;42000;004;https://qra-team.online;0" >> /root/YSFHosts.txt
fi

# Add custom XLX Hosts
if [ -f "/root/XLXHosts.txt" ]; then
	cat /root/XLXHosts.txt >> ${XLXHOSTS}
fi

# Add custom P25Hosts.txt
if [ -f "/root/P25Hosts.txt" ]; then
	cat /root/P25Host.txt >> ${P25HOSTS}
fi

# Add custom DMR_Hosts.txt
if [ -f "/root/DMR_Hosts.txt" ]; then
	cat /root/DMR_Hosts.txt >> ${DMRHOSTS}
fi

# Add custom YSFHosts.txt
if [ -f "/root/YSFHosts.txt" ]; then
	cat /root/YSFHosts.txt >> ${YSFHOSTS}
fi



# Add QRA DMRID database
curl --fail -o /tmp/DMRIdsQRA.dat -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMRIds.dat"
cat /tmp/DMRIdsQRA.dat >> ${DMRIDFILE}



 # run any slipstream tasks
bash /usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2>&1
echo -e "  ${TICK} Done!" # maint. complete
echo -e "\n${BULL} Starting WPSD Services. Please wait..."
wpsd-services start > /dev/null 2>&1
echo -e "  ${TICK} Done!\n"

#sudo systemctl reboot

exit 0


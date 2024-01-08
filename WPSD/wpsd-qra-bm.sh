#!/bin/bash
#
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"
dmrgateway=/etc/dmrgateway


if [ "$(id -u)" != "0" ]; then
    echo -e "You need to be root to run this command...\n"
exit 1
fi


echo "Set rpi-rw"
mount -o remount,rw / ; mount -o remount,rw /boot

echo -e "${BULL} Stopping Cron Services. Please wait..."
systemctl stop cron.service > /dev/null 2<&1
pkill pistar-hourly.cron > /dev/null 2>&1
pkill pistar-daily.cron > /dev/null 2>&1
echo -e "  ${TICK} Done!\n"


curl --fail -o /root/wpsd-update.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/WPSD/wpsd-update.sh

chmod 775 /root/wpsd-update.sh > /dev/null 2>&1
chown -R root:root /root/wpsd-update.sh > /dev/null 2>&1
cp -f /root/wpsd-update.sh /usr/local/sbin/ > /dev/null 2>&1


if grep 'usr/local/sbin/wpsd-update.sh' /etc/cron.daily/pistar-daily  ; then
    echo "Skip!"
else
    echo "------- Configure pistar.daily"
    echo "pause 10" >> /etc/cron.daily/pistar-daily
    echo "/usr/local/sbin/wpsd-update.sh" >> /etc/cron.daily/pistar-daily
fi

#if grep 'usr/local/sbin/wpsd-update.sh' /etc/cron.hourly/pistar-hourly  ; then
#    echo "Skip!"
#else
#  echo "------- Configure pistar.hourly"
#  echo "pause 10" >> /etc/cron.hourly/pistar-hourly
#  echo "/usr/local/sbin/wpsd-update.sh" >> /etc/cron.hourly/pistar-hourly
#fi

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

echo "Start Update Script"
/usr/local/sbin/wpsd-update.sh
echo "------------"


echo " "
echo -e "${GRN}------------>  Обновление завершено...${NC}"
echo " "
echo -e "${GRN}------------>  Добро Пожаловать в QRA + BM!${NC}"
exit 0


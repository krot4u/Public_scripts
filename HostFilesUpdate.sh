#!/bin/bash
export LC_ALL=C

NEWVERSION=13012024
CURRENTVERSION=$(grep -E '[0-8]+' /var/www/dashboard/config/version.php | awk -F"'" '{print $2}')

echo "Current version HostFilesUpdate is ${CURRENTVERSION}"

if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
  exit 0
fi

DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
DCSHOSTS=/usr/local/etc/DCS_Hosts.txt
DExtraHOSTS=/usr/local/etc/DExtra_Hosts.txt
P25HOSTS=/usr/local/etc/P25Hosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt
YSFHOSTS=/usr/local/etc/YSFHosts.txt
FCSHOSTS=/usr/local/etc/FCSHosts.txt
MPISTAR=/usr/local/sbin/mpi-star.sh
PISTARHOURLY=/usr/local/sbin/pistar-hourly.cron
# How many backups
FILEBACKUP=1

# Check we are root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
  cp ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
  cp ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
  cp ${P25HOSTS} ${P25HOSTS}.$(date +%Y%m%d)
  cp ${XLXHOSTS} ${XLXHOSTS}.$(date +%Y%m%d)
fi

# Prune backups
FILES="
${DMRIDFILE}
${DMRHOSTS}
${P25HOSTS}
${XLXHOSTS}"

echo ">> HostFilesUpdate: backup files"
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

echo ">> HostFilesUpdate: Download config files"
# Generate Host Files
curl --fail -o ${DMRHOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMR_Hosts.txt
curl --fail -o ${DMRIDFILE} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMRIds.dat
curl --fail -o ${DCSHOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DCS_Hosts.txt
curl --fail -o ${DExtraHOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DExtra_Hosts.txt
curl --fail -o ${P25HOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/P25_Hosts.txt
curl --fail -o ${XLXHOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/XLXHosts.txt
curl --fail -o ${FCSHOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/FCSHosts.txt
curl --fail -o ${YSFHOSTS} -s http://kavkaz.qrz.ru/YSF_Hosts.txt
curl --fail -o ${MPISTAR} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mpi-star.sh
curl --fail -o ${PISTARHOURLY} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-hourly.cron
curl --fail -o "/root/YSFHosts.txt" -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/YSF_Hosts.txt
curl --fail -o "/usr/local/etc/dmrid.dat" -s https://qra-team.online/files/dmrid.dat

# SendLogs script
curl --fail -o /usr/local/sbin/sendLogs.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/sendLogs.sh
chmod +x /usr/local/sbin/sendLogs.sh

echo ">> HostFilesUpdate: Run mpi-star.sh"
chmod +x ${MPISTAR}
${MPISTAR} 2> /dev/null
echo "------------"

# Pi-Star Dashboar modifications
if [[ $NEWVERSION != $CURRENTVERSION ]]; then
  echo ">> HostFilesUpdate: Download dashboard files"
  mount -o remount,rw /
  mount -o remount,rw /boot
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/index.php" > '/var/www/dashboard/index.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/dmridlist.php" > '/var/www/dashboard/dmridlist.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/css/pistar-css.php" > '/var/www/dashboard/css/pistar-css.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/lang/russian_ru.php" > '/var/www/dashboard/lang/russian_ru.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/lang/english_uk.php" > '/var/www/dashboard/lang/english_uk.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/config/language.php" > '/var/www/dashboard/admin/config/language.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/index.php" > '/var/www/dashboard/admin/index.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/update.php" > '/var/www/dashboard/admin/update.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/configure.php" > '/var/www/dashboard/admin/configure.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/expert/header-menu.inc" > '/var/www/dashboard/admin/expert/header-menu.inc'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/power.php" > '/var/www/dashboard/admin/power.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/config_backup.php" > '/var/www/dashboard/admin/config_backup.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/live_modem_log.php" > '/var/www/dashboard/admin/live_modem_log.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/css/pistar-css.php" > '/var/www/dashboard/admin/css/pistar-css.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/calibration.php" > '/var/www/dashboard/admin/calibration.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/sysinfo.php" > '/var/www/dashboard/admin/sysinfo.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/expert/index.php" > '/var/www/dashboard/admin/expert/index.php'
  curl --fail -o '/var/www/dashboard/admin/images/header.png' -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/images/header.png"
  curl --fail -o '/var/www/dashboard/images/header.png' -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/images/header.png"
  curl --fail -o /etc/pistar-css.ini -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-css.ini
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/sendlogs.php" > '/var/www/dashboard/admin/sendlogs.php'
fi

# Custom P25Hosts.txt
if [ -f "/root/P25Hosts.txt" ]; then
  echo ">> Update with custom P25Hosts"
  cat /root/P25Hosts.txt > /usr/local/etc/P25HostsLocal.txt
  echo "------------"
fi

# Custom DMR_Hosts.txt
if [ -f "/root/DMR_Hosts.txt" ]; then
  echo ">> Update with custom DMR_Hosts"
  sed -i -e '$a\' ${DMRHOSTS}
  cat /root/DMR_Hosts.txt >> ${DMRHOSTS}
  echo "------------"
fi

# Custom XLXHosts.txt
if [ -f "/root/XLXHosts.txt" ]; then
  echo ">> Update with custom XLXHosts"
  sed -i -e '$a\' ${XLXHOSTS}
  cat /root/XLXHosts.txt >> ${XLXHOSTS}
  echo "------------"
fi

# Custom YSFHosts.txt
if [ -f "/root/YSFHosts.txt" ]; then
  echo ">> Update with custom YSFHosts"
  sed -i -e '$a\' ${YSFHOSTS}
  cat /root/YSFHosts.txt >> ${YSFHOSTS}
  echo "------------"
fi

# Yaesu FT-70D radios only do upper case
if [ -f "/etc/hostfiles.ysfupper" ]; then
  sed -i 's/\(.*\)/\U\1/' ${YSFHOSTS}
  sed -i 's/\(.*\)/\U\1/' ${FCSHOSTS}
fi

sed -i "s/\$version = '.*';/\$version = '$NEWVERSION';/" "/var/www/dashboard/config/version.php"
echo ">> HostFilesUpdate: Done! Exiting..."

exit 0
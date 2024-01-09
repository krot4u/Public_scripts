#!/bin/bash

NEWVERSION=09012024
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
if [ "$(id -u)" != "0" ];then
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

chmod +x ${MPISTAR}
${MPISTAR} 2> /dev/null
echo "------------"

echo ">> HostFilesUpdate: Download dashboard files"
mount -o remount,rw /
mount -o remount,rw /boot

# Pi-Star Dashboar modifications
if [[ $NEWVERSION != $CURRENTVERSION ]]
then
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/index.php" > '/var/www/dashboard/index.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/dmridlist.php" > '/var/www/dashboard/dmridlist.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/css/pistar-css.php" > '/var/www/dashboard/css/pistar-css.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/lang/russian_ru.php" > '/var/www/dashboard/lang/russian_ru.php'
  curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/lang/english_uk.php" > '/var/www/dashboard/lang/english_uk.php'
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
  # curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/mmdvmhost/lh.php" > '/var/www/dashboard/admin/mmdvmhost/lh.php'
  # curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/mmdvmhost/localtx.php" > '/var/www/dashboard/admin/mmdvmhost/localtx.php'
  # curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/mmdvmhost/repeaterinfo.php" > '/var/www/dashboard/admin/mmdvmhost/repeaterinfo.php'
  # curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/mmdvmhost/lh.php" > '/var/www/dashboard/mmdvmhost/lh.php'
  # curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/mmdvmhost/localtx.php" > '/var/www/dashboard/mmdvmhost/localtx.php'
  # curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/mmdvmhost/repeaterinfo.php" > '/var/www/dashboard/mmdvmhost/repeaterinfo.php'
  curl --fail -o '/var/www/dashboard/admin/images/header.png' -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/images/header.png"
  curl --fail -o '/var/www/dashboard/images/header.png' -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/images/header.png"

  curl --fail -o /etc/pistar-css.ini -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-css.ini
# cat <<EOF > /opt/version
# ${NEWVERSION}
# EOF

# Add custom YSF Hosts
if [ -f "/root/YSFHosts.txt" ]; then
	cat /root/YSFHosts.txt >> ${YSFHOSTS}
fi

sed -i "s/\$version = '.*';/\$version = '$NEWVERSION';/" /var/www/dashboard/config/version.php
fi

echo "------------"
echo ">> HostFilesUpdate: Done... Exiting..."

exit 0
#!/bin/bash

if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
  exit 0
fi

DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
P25HOSTS=/usr/local/etc/P25Hosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt

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
curl --fail -o ${P25HOSTS} -s http://www.pistar.uk/downloads/P25_Hosts.txt
curl --fail -o ${XLXHOSTS} -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/XLXHosts.txt
curl --fail -o '/usr/local/sbin/mpi-star.sh' -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mpi-star.sh
curl --fail -o '/usr/local/sbin/dwldashboard.sh' -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dwldashboard.sh
curl --fail -o '/usr/local/sbin/pistar-hourly.cron' -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/pistar-hourly.cron

chmod +x /usr/local/sbin/mpi-star.sh
/usr/local/sbin/mpi-star.sh 2> /dev/null
echo "------------"

echo ">> HostFilesUpdate: Download dashboard files"
chmod +x /usr/local/sbin/dwldashboard.sh
/usr/local/sbin/dwldashboard.sh
echo "------------"

echo ">> HostFilesUpdate: Done... Exiting..."

exit 0
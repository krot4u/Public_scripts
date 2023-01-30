#!/bin/bash
#########################################################
#                                                       #
#              HostFilesUpdate.sh Updater               #
#                                                       #
#      Written for Pi-Star (http://www.pistar.uk/)      #
#               By Andy Taylor (MW0MWZ)                 #
#                                                       #
#                     Version 2.6                       #
#                                                       #
#   Based on the update script by Tony Corbett G0WFV    #
#                                                       #
#########################################################
# fix
# Check that the network is UP and die if its not
if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
        exit 0
fi

# Get the Pi-Star Version
pistarCurVersion=$(awk -F "= " '/Version/ {print $2}' /etc/pistar-release)

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
FILES="${APRSHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${P25HOSTS}
${XLXHOSTS}

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

# Generate Host Files
curl --fail -o ${DMRHOSTS} -s https://github.com/krot4u/Public_scripts/blob/master/DMR_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${DMRIDFILE} -s https://github.com/krot4u/Public_scripts/blob/master/DMRIds.dat --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${P25HOSTS} -s http://www.pistar.uk/downloads/P25_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}"
curl --fail -o ${XLXHOSTS} -s https://github.com/krot4u/Public_scripts/blob/master/XLXHosts.txt --user-agent "Pi-Star_${pistarCurVersion}"

exit 0
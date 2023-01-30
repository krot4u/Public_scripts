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

# Check that the network is UP and die if its not
if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
        exit 0
fi

# Get the Pi-Star Version
pistarCurVersion=$(awk -F "= " '/Version/ {print $2}' /etc/pistar-release)

APRSHOSTS=/usr/local/etc/APRSHosts.txt
DCSHOSTS=/usr/local/etc/DCS_Hosts.txt
DExtraHOSTS=/usr/local/etc/DExtra_Hosts.txt
DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
DPlusHOSTS=/usr/local/etc/DPlus_Hosts.txt
P25HOSTS=/usr/local/etc/P25Hosts.txt
M17HOSTS=/usr/local/etc/M17Hosts.txt
YSFHOSTS=/usr/local/etc/YSFHosts.txt
FCSHOSTS=/usr/local/etc/FCSHosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt
NXDNIDFILE=/usr/local/etc/NXDN.csv
NXDNHOSTS=/usr/local/etc/NXDNHosts.txt
TGLISTBM=/usr/local/etc/TGList_BM.txt
TGLISTP25=/usr/local/etc/TGList_P25.txt
TGLISTNXDN=/usr/local/etc/TGList_NXDN.txt
TGLISTYSF=/usr/local/etc/TGList_YSF.txt

# How many backups
FILEBACKUP=1

# Check we are root
if [ "$(id -u)" != "0" ];then
        echo "This script must be run as root" 1>&2
        exit 1
fi

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
        cp ${APRSHOSTS} ${APRSHOSTS}.$(date +%Y%m%d)
        cp ${DCSHOSTS} ${DCSHOSTS}.$(date +%Y%m%d)
        cp ${DExtraHOSTS} ${DExtraHOSTS}.$(date +%Y%m%d)
        cp ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
        cp ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
        cp ${DPlusHOSTS} ${DPlusHOSTS}.$(date +%Y%m%d)
        cp ${P25HOSTS} ${P25HOSTS}.$(date +%Y%m%d)
        cp ${M17HOSTS} ${M17HOSTS}.$(date +%Y%m%d)
        cp ${YSFHOSTS} ${YSFHOSTS}.$(date +%Y%m%d)
        cp ${FCSHOSTS} ${FCSHOSTS}.$(date +%Y%m%d)
        cp ${XLXHOSTS} ${XLXHOSTS}.$(date +%Y%m%d)
        cp ${NXDNIDFILE} ${NXDNIDFILE}.$(date +%Y%m%d)
        cp ${NXDNHOSTS} ${NXDNHOSTS}.$(date +%Y%m%d)
        cp ${TGLISTBM} ${TGLISTBM}.$(date +%Y%m%d)
        cp ${TGLISTP25} ${TGLISTP25}.$(date +%Y%m%d)
        cp ${TGLISTNXDN} ${TGLISTNXDN}.$(date +%Y%m%d)
        cp ${TGLISTYSF} ${TGLISTYSF}.$(date +%Y%m%d)
fi

# Prune backups
FILES="${APRSHOSTS}
${DCSHOSTS}
${DExtraHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${DPlusHOSTS}
${P25HOSTS}
${M17HOSTS}
${YSFHOSTS}
${FCSHOSTS}
${XLXHOSTS}
${NXDNIDFILE}
${NXDNHOSTS}
${TGLISTBM}
${TGLISTP25}
${TGLISTNXDN}
${TGLISTYSF}"

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
#curl --fail -s http://www.pistar.uk/downloads/USTrust_Hosts.txt --user-agent "Pi-Star_${pistarCurVersion}" >> ${DExtraHOSTS}
curl --fail -o ${XLXHOSTS} -s https://github.com/krot4u/Public_scripts/blob/master/XLXHosts.txt --user-agent "Pi-Star_${pistarCurVersion}"

# Fix DMRGateway issues with brackets
if [ -f "/etc/dmrgateway" ]; then
        sed -i '/Name=.*(/d' /etc/dmrgateway
        sed -i '/Name=.*)/d' /etc/dmrgateway
fi

# Add some fixes for P25Gateway
if [[ $(/usr/local/bin/P25Gateway --version | awk '{print $3}' | cut -c -8) -gt "20180108" ]]; then
        sed -i 's/Hosts=\/usr\/local\/etc\/P25Hosts.txt/HostsFile1=\/usr\/local\/etc\/P25Hosts.txt\nHostsFile2=\/usr\/local\/etc\/P25HostsLocal.txt/g' /etc/p25gateway
        sed -i 's/HostsFile2=\/root\/P25Hosts.txt/HostsFile2=\/usr\/local\/etc\/P25HostsLocal.txt/g' /etc/p25gateway
fi
if [ -f "/root/P25Hosts.txt" ]; then
        cat /root/P25Hosts.txt > /usr/local/etc/P25HostsLocal.txt
fi

exit 0
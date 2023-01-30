#!/bin/bash
# CONFIG_DMRID=5973272; CONFIG_CALLSIGN=TURBO; CONFIG_FREQUENCY=433500000
echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh https://github.com/krot4u/Public_scripts/blob/master/HostFilesUpdate.sh
/usr/local/sbin/HostFilesUpdate.sh

sed -i "s/--Frequency--/${CONFIG_FREQUENCY}/" /etc/dmrgateway
sed -i "s/--DMRID--/${CONFIG_DMRID}/" /etc/dmrgateway

sed -i "s/--CALLSIGN--/Type=${CONFIG_CALLSIGN}/" /etc/mmdvmhost
sed -i "s/--DMRID--/Type=${CONFIG_DMRID}/" /etc/mmdvmhost

echo "Run pi-star update..."
/usr/local/sbin/pistar-update

echo "Done! Exiting..."
#!/bin/bash
# export CONFIG_DMRID=5973272 CONFIG_CALLSIGN=TURBO CONFIG_FREQUENCY=433500000
set -e
DMRID="${CONFIG_DMRID:-7777777}"
FREQUENCY="${CONFIG_FREQUENCY:-431500000}"
CALLSIGN="${CONFIG_CALLSIGN:-000}"

echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh
/bin/bash /usr/local/sbin/HostFilesUpdate.sh

echo "Downloading modified dmrgateway and mmdvmhost..."
curl --fail -o /etc/dmrgateway -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrgateway.ini
curl --fail -o /etc/mmdvmhost -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mmdvmhost.ini

echo "Updating dmrgateway and mmdvmhost..."
sed -i "s/--Frequency--/$FREQUENCY/" /etc/dmrgateway
sed -i "s/--DMRID--/$DMRID/" /etc/dmrgateway

sed -i "s/--CALLSIGN--/Type=$CALLSIGN/" /etc/mmdvmhost
sed -i "s/--DMRID--/Type=$DMRID/" /etc/mmdvmhost

echo "Run pi-star update..."
/usr/local/sbin/pistar-update

echo "Done! Exiting..."
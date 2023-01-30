#!/bin/bash
# export CONFIG_DMRID=5973272 CONFIG_CALLSIGN=TURBO CONFIG_FREQUENCY=433500000
DMRID="${CONFIG_DMRID:-7777777}"
FREQUENCY="${CONFIG_FREQUENCY:-431500000}"
CALLSIGN="${CONFIG_CALLSIGN:-000}"

echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh https://github.com/krot4u/Public_scripts/blob/master/HostFilesUpdate.sh
/bin/bash /usr/local/sbin/HostFilesUpdate.sh

curl --fail -o /etc/dmrgateway https://github.com/krot4u/Public_scripts/blob/master/dmrgateway.ini
curl --fail -o /etc/mmdvmhost https://github.com/krot4u/Public_scripts/blob/master/mmdvmhost.ini

sed -i "s/--Frequency--/$FREQUENCY/" /etc/dmrgateway
sed -i "s/--DMRID--/$DMRID/" /etc/dmrgateway

sed -i "s/--CALLSIGN--/Type=$CALLSIGN/" /etc/mmdvmhost
sed -i "s/--DMRID--/Type=$DMRID/" /etc/mmdvmhost

echo "Run pi-star update..."
/usr/local/sbin/pistar-update

echo "Done! Exiting..."
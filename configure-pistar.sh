#!/bin/bash
# export CONFIG_DMRID=5973272 CONFIG_CALLSIGN=TURBO CONFIG_FREQUENCY=433500000
DMRID="${CONFIG_DMRID:-7777777}"
FREQUENCY="${CONFIG_FREQUENCY:-431500000}"
CALLSIGN="${CONFIG_CALLSIGN:-000}"

if [ "$(id -u)" != "0" ];then
        echo "This script must be run as root" 1>&2
        exit 1
fi

service_handle() {
	# What do we want do to?
	doWhat=${1}

	systemctl ${doWhat} pistar-watchdog.service > /dev/null 2>&1
	systemctl ${doWhat} pistar-remote.service > /dev/null 2>&1
	systemctl ${doWhat} dmrgateway.service > /dev/null 2>&1
	systemctl ${doWhat} dapnetgateway.service > /dev/null 2>&1
	systemctl ${doWhat} ircddbgateway.service > /dev/null 2>&1
	systemctl ${doWhat} timeserver.service > /dev/null 2>&1
	systemctl ${doWhat} ysfgateway.service > /dev/null 2>&1
	systemctl ${doWhat} ysf2dmr.service > /dev/null 2>&1
	systemctl ${doWhat} ysf2nxdn.service > /dev/null 2>&1
	systemctl ${doWhat} ysf2p25.service > /dev/null 2>&1
	systemctl ${doWhat} ysfparrot.service > /dev/null 2>&1
	systemctl ${doWhat} dmr2ysf.service > /dev/null 2>&1
	systemctl ${doWhat} dmr2nxdn.service > /dev/null 2>&1
	systemctl ${doWhat} p25gateway.service > /dev/null 2>&1
	systemctl ${doWhat} p25parrot.service > /dev/null 2>&1
	systemctl ${doWhat} nxdngateway.service > /dev/null 2>&1
	systemctl ${doWhat} nxdn2dmr.service > /dev/null 2>&1
	systemctl ${doWhat} nxdnparrot.service > /dev/null 2>&1
	systemctl ${doWhat} dstarrepeater.service > /dev/null 2>&1
	systemctl ${doWhat} mmdvmhost.service > /dev/null 2>&1 && sleep 2 > /dev/null 2>&1
}

echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

echo "Stopping Services..."
service_handle stop
echo "Done"

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
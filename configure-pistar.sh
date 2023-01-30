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

	systemctl ${doWhat} pistar-watchdog.service
	systemctl ${doWhat} pistar-remote.service
	systemctl ${doWhat} dmrgateway.service
	systemctl ${doWhat} dapnetgateway.service
	systemctl ${doWhat} ircddbgateway.service
	systemctl ${doWhat} timeserver.service
	systemctl ${doWhat} ysfgateway.service
	systemctl ${doWhat} ysf2dmr.service
	systemctl ${doWhat} ysf2nxdn.service
	systemctl ${doWhat} ysf2p25.service
	systemctl ${doWhat} ysfparrot.service
	systemctl ${doWhat} dmr2ysf.service
	systemctl ${doWhat} dmr2nxdn.service
	systemctl ${doWhat} p25gateway.service
	systemctl ${doWhat} p25parrot.service
	systemctl ${doWhat} nxdngateway.service
	systemctl ${doWhat} nxdnparrot.service
	systemctl ${doWhat} dstarrepeater.service
	systemctl ${doWhat} mmdvmhost.service && sleep 3
}

echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/HostFilesUpdate.sh

echo "Stopping Services..."
service_handle stop
echo "Done"
echo "------------"
/bin/bash /usr/local/sbin/HostFilesUpdate.sh

echo "Backup /etc/dmrgateway and /etc/mmdvmhost"
cp /etc/dmrgateway /etc/dmrgateway.$(date +%Y%m%d)
cp /etc/mmdvmhost /etc/mmdvmhost.$(date +%Y%m%d)
echo "Removing /etc/dmrgateway and /etc/mmdvmhost"
rm -f /etc/dmrgateway
rm -f /etc/mmdvmhost

echo "Downloading modified dmrgateway and mmdvmhost..."
curl --fail -o /etc/dmrgateway -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrgateway.ini
curl --fail -o /etc/mmdvmhost -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/mmdvmhost.ini
echo "Done"
echo "------------"
echo "Updating dmrgateway and mmdvmhost..."
sed -i "s/--Frequency--/$FREQUENCY/" /etc/dmrgateway
sed -i "s/--DMRID--/$DMRID/" /etc/dmrgateway

sed -i "s/--CALLSIGN--/$CALLSIGN/" /etc/mmdvmhost
sed -i "s/--DMRID--/Type=$DMRID/" /etc/mmdvmhost
echo "Done"
echo "------------"
echo "Run pi-star update..."
/usr/local/sbin/pistar-update
echo "------------"
echo "Done! Exiting..."
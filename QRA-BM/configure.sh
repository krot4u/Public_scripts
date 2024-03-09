#!/bin/bash
export LC_ALL=C

echo "------------ Download Configurator"
pistarHardware=$(awk -F "= " '/Hardware/ {print $2}' /etc/pistar-release)
if [ "${pistarHardware}" == "NanoPi" ]; then
  curl --fail -o /tmp/configureQRABM.sh -s https://s3.qra-team.online/PiStar/configureQRABM-nano
else
  curl --fail -o /tmp/configureQRABM.sh -s https://s3.qra-team.online/PiStar/configureQRABM-rpi
fi
echo "------------"

echo "------------ Run Configurator"
chmod +x /tmp/configureQRABM.sh
/tmp/configureQRABM.sh
rm -rf /tmp/configureQRABM.sh
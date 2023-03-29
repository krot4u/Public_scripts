#!/bin/bash

# Load RRD tool for Ping Server
if [[ -f /opt/.rrdtool ]]
then
  exit 0
else
  curl --fail -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/rrd/rrd_setup.sh | bash
fi

# --- Enable voice on Sanich Pi-Star
CALLSIGN=$(sudo cat /etc/mmdvmhost | grep Callsign=SANICH)

if [[ "x$CALLSIGN" == "xSANICH" ]] ; then
  ## set directly
  rpi-rw
  sed -i -E "/^\[Voice\]$/,/^\[/ s/^Enabled=.*/Enabled=1/" /etc/dmrgateway
  rpi-ro
else
  exit 0
fi
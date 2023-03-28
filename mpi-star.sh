#!/bin/bash

CALLSIGN=$(sudo cat /etc/mmdvmhost | grep Callsign=TASKENT)

if [[ "x$CALLSIGN" == "xSANICH" ]] ; then
  ## set directly
  rpi-rw

  sed -i -E "/^\[Voice\]$/,/^\[/ s/^Enabled=.*/Enabled=1/" /etc/dmrgateway
  rpi-ro
else
  exit 0
fi
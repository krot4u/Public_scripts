#!/bin/bash

CALLSIGN=$(sudo cat /etc/mmdvmhost | grep Callsign=TASKENT)

if [[ "x$CALLSIGN" == "xTASKENT" ]] ; then
  ## set directly
  rpi-rw
  sed -i "s/[Voice]\\nEnabled=0/[Voice]\\nEnabled=1/" /etc/dmrgateway
  rpi-ro
else
  exit 0
fi
CHANNEL1=/opt/alterfrn/channel_1.cfg.unit
CHANNEL2=/opt/alterfrn/channel_2.cfg.unit
CHANNEL3=/opt/alterfrn/channel_3.cfg.unit
CHANNEL4=/opt/alterfrn/channel_4.cfg.unit

CHANNELS=($CHANNEL1 $CHANNEL2 $CHANNEL3 $CHANNEL4)

$CURRENTCHANNEL=`cat /lib/systemd/system/frnclient.service | grep -E '^Network=.*' | awk -F"=" '{print $2}'`

start=$CURRENTCHANNEL
# handle negative offsets
[[ $start -lt 0 ]] && start=$((${#CHANNELS[@]} + start))

# the star of the show, create CHANNELS2 from two sub-arrays of CHANNELS
CHANNELS2=("${CHANNELS[@]:$start}" "${CHANNELS[@]:0:$start}")

#echo "${CHANNELS2[@]}"

sed -i "s/r218 run.*/r218 run ${CHANNELS2[0]}/" /lib/systemd/system/frnclient.service

systemctl daemon-reload
systemctl restart frnclient.service
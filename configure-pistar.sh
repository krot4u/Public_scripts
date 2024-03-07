#!/bin/bash
export LC_ALL=C
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

function rpirw {
  echo "rpirw..."
  sudo mount -o remount,rw /
  sudo mount -o remount,rw /boot
  echo "------------"
}

if [ "$(id -u)" != "0" ];then
        echo "Ошибка! Необходимо выполнить ${GRN}sudo su - ${NC}" 1>&2
        exit 1
fi

read_dmrid() {
	while true; do
		read -p "Введите Ваш DMRID (7 цифр): " DMRID
		len=`echo ${DMRID} |awk '{print length}'`
		if [[ ( ${DMRID} != ^[[:digit:]]+$ ) && ( $len -ne 7 ) ]];then
			echo "----->"
			echo -e "   ${RED}Ошибка: Неправильный DMRID!${NC}" 1>&2
			echo "----->"
			echo " "
		else
			echo "----->"
			echo -e "   ${GRN}Ваш DMRID ${DMRID} ${NC}"
			echo "----->"
			echo " "
			break
		fi
	done
}

read_frequency() {
  while true; do
    echo "Введите частоту приёма/передачи на ХотСпоте (разделитель точка)"
    read -p "(9 цифр. Пример: 433.500.000): " MFREQUENCY
    FREQUENCY=$(echo "${MFREQUENCY//./}")
    FIRST=${MFREQUENCY:0:3}
    len=${#FREQUENCY}
    if ! [[ "$MFREQUENCY" =~ ^[0-9]{3}\.[0-9]{3}\.[0-9]{3}$ ]] || [ $len -ne 9 ]; then
      echo "----->"
      echo -e "   ${RED}Ошибка: Неверная частота!${NC}" 1>&2
      echo "----->"
      echo " "
    else
      echo " "
    fi
    if ! ([[ $FIRST -ge 144 && $FIRST -le 148 ]] || [[ $FIRST -ge 220 && $FIRST -le 225 ]] || [[ $FIRST -ge 420 && $FIRST -le 450 ]] || [[ $FIRST -ge 842 && $FIRST -le 950 ]]); then
      echo -e "   ${RED}Ошибка: Эта частота не разрешена для использования!${NC}" 1>&2
    else
      echo "----->"
      echo -e "   ${GRN}Частота приёма/передачи ${MFREQUENCY} ${NC}"
      echo "----->"
      echo " "
      break
    fi
  done
}

export FREQUENCY=${FREQUENCY}
export MFREQUENCY=${MFREQUENCY}
export DMRID=${DMRID}

echo ">> QRAconfig: Download QRApistar.sh"
pistarHardware=$(awk -F "= " '/Hardware/ {print $2}' /etc/pistar-release)
if [ "${pistarHardware}" == "NanoPi" ]; then
  curl --fail -o /usr/local/sbin/QRApistar.sh -s https://s3.qra-team.online/PiStar/QRApistar-nano
  echo ">> QRAconfig: Starting QRApistar.sh..."
  /usr/local/sbin/QRApistar.sh
else
  curl --fail -o /usr/local/sbin/QRApistar.sh -s https://s3.qra-team.online/PiStar/QRApistar-rpi
  echo ">> QRAconfig: Starting QRApistar.sh..."
  /usr/local/sbin/QRApistar.sh
fi
#!/bin/bash

export LC_ALL=C
RED="\033[0;31m"
GRN="\033[0;32m"
NC="\033[0m"

read_frequency() {
  while true; do
    echo "Введите частоту приёма/передачи на ХотСпоте."
    read -p "(9 цифр. Пример: 433.500.000): " MFREQUENCY
    FREQ=$(echo "${MFREQUENCY//./}")
    FIRST=${MFREQUENCY:0:3}
    len=${#FREQ}
    if ! [[ "$MFREQUENCY" =~ ^[[:digit:]].[[:digit:]].[[:digit:]]$ ]] && [ $len -ne 9 ]; then
      echo "----->"
      echo -e "   ${RED}Ошибка: Неверная частота!${NC}" 1>&2
      echo "----->"
      echo " "
    elif [[ $FIRST -ge 144 && $FIRST -le 148 ]] || [[ $FIRST -ge 220 && $FIRST -le 225 ]] || [[ $FIRST -ge 420 && $FIRST -le 450 ]] || [[ $FIRST -ge 842 && $FIRST -le 950 ]]; then
      echo -e "   ${RED}Ошибка: Эта частота не разрешена для использования!${NC}" 1>&2
    else
      echo "----->"
      echo -e "   ${GRN}Частота приёма/передачи ${MFREQUENCY} ${NC}"
      echo "----->"
      echo " "
      FREQUENCY="${MFREQUENCY//./}"
      break
    fi
  done
}

read_frequency </dev/tty
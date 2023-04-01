#!/bin/bash
echo "Начало..."
dmridqra=`cat /usr/local/sbin/HostFilesUpdate.sh | grep 'krot4u/Public_scripts/master/DMRIds.dat'`
if [ ! -z "$dmridqra" ]
  then
    sed -i '/DMRIds.dat --user-agent "Pi-Star_${pistarCurVersion}"/a curl --fail -o /usr/local/etc/DMRIdsQRA.dat -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMRIds.dat' /usr/local/sbin/HostFilesUpdate.sh
    sed -i '/curl --fail -o \/usr\/local\/etc\/DMRIdsQRA.dat -s https:\/\/raw.githubusercontent.com\/krot4u\/Public_scripts\/master\/DMRIds.dat/a cat \/usr\/local\/etc\/DMRIdsQRA.dat | echo >> \/usr\/local\/etc\/DMRIds.dat' /usr/local/sbin/HostFilesUpdate.sh
else
  exit 0
fi

echo "Готово!"
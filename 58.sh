#!/bin/bash
curl --fail -o /usr/local/etc/DMRIds.dat -s http://www.pistar.uk/downloads/DMRIds.dat --user-agent "Pi-Star_${pistarCurVersion}"
sed -i '/DMRIds.dat --user-agent "Pi-Star_${pistarCurVersion}"/a curl --fail -o /usr/local/etc/DMRIdsQRA.dat -s https://raw.githubusercontent.com/krot4u/Public_scripts/master/DMRIds.dat' HostFilesUpdate.sh
sed -i '/curl --fail -o \/usr\/local\/etc\/DMRIdsQRA.dat -s https:\/\/raw.githubusercontent.com\/krot4u\/Public_scripts\/master\/DMRIds.dat/a cat \/usr\/local\/etc\/DMRIdsQRA.dat | echo >> \/usr\/local\/etc\/DMRIds.dat' HostFilesUpdate.sh
#!/bin/bash

# Pi-Star Dashboar modifications
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/index.php" > '/var/www/dashboard/index.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/css/pistar-css.php" > '/var/www/dashboard/css/pistar-css.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/lang/russian_ru.php" > '/var/www/dashboard/lang/russian_ru.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/lang/english_uk.php" > '/var/www/dashboard/lang/english_uk.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/index.php" > '/var/www/dashboard/admin/index.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/update.php" > '/var/www/dashboard/admin/update.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/configure.php" > '/var/www/dashboard/admin/configure.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/expert/header-menu.inc" > '/var/www/dashboard/admin/expert/header-menu.inc'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/power.php" > '/var/www/dashboard/admin/power.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/config_backup.php" > '/var/www/dashboard/admin/config_backup.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/live_modem_log.php" > '/var/www/dashboard/admin/live_modem_log.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/css/pistar-css.php" > '/var/www/dashboard/admin/css/pistar-css.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/calibration.php" > '/var/www/dashboard/admin/calibration.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/sysinfo.php" > '/var/www/dashboard/admin/sysinfo.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/expert/index.php" > '/var/www/dashboard/admin/expert/index.php'
curl --fail -o '/var/www/dashboard/admin/images/header.png' -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/images/header.png"
curl --fail -o '/var/www/dashboard/images/header.png' -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/images/header.png"
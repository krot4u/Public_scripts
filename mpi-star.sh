#!/bin/bash
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/index.php" > '/var/www/dashboard/index.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/index.php" > '/var/www/dashboard/admin/index.php'
curl --fail -s "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dashboard/admin/expert/index.php" > '/var/www/dashboard/admin/expert/index.php'

#!/bin/bash
echo "Downloading modified HostFilesUpdate.sh..."
curl --fail -o /usr/local/sbin/HostFilesUpdate.sh https://github.com/krot4u/Public_scripts/blob/master/HostFilesUpdate.sh
/usr/local/sbin/HostFilesUpdate.sh
echo "Run pi-star update..."
/usr/local/sbin/pistar-update
echo "Done! Exiting..."
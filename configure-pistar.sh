#!/bin/bash

sed -i "s/curl --fail -o \$\{DMRHOSTS\}/#curl --fail -o \$\{DMRHOSTS\}/" /usr/local/sbin/HostFilesUpdate.sh

sed -i "s/curl --fail -o /$\{DMRHOSTS}/#curl --fail -o /$\{DMRHOSTS}/" ./HostFilesUpdate.sh
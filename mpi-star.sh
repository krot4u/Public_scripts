#!/bin/bash
if [ ! -d '/var/log/testlog' ]
  then
    mkdir /var/log/testlog
fi

touch /var/log/testlog/testlog.log
echo "my test" > /var/log/testlog/testlog.log
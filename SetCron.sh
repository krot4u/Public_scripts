if ! $(cat /tmp/crontab.tmp | grep -q "shutdown"); then
  echo "0 3 * * * /sbin/shutdown -r +20" >> /tmp/crontab.tmp
  crontab /tmp/crontab.tmp
  rm -f /tmp/crontab.tmp
else
  echo "Nothing to do. Exiting..."
fi
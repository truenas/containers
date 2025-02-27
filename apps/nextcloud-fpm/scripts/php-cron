#!/bin/sh
set -e

uid="$(id -u)"
gid="$(id -g)"

if [ "$uid" = '0' ]; then
  user='www-data'
  group='www-data'
else
  user="$uid"
  group="$gid"
fi

if [ "$(id -u)" = 0 ]; then
  su -p "$user" -s /bin/bash -c 'php /var/www/html/cron.php'
else
  /bin/bash -c 'php /var/www/html/cron.php'
fi

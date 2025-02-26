#!/bin/sh
set -e

while [ ! -f "/var/www/html/lib/versioncheck.php" ]; do
  echo 'Waiting Nextcloud to be installed...'
  echo 'Sleeping for 2m...'
  sleep 2m
done

cron_file="${CRON_TAB_FILE:-/crontasks}"

# Test crontab file
echo "Testing crontab file ${cron_file}"
echo "You might see some parsing errors here, but if the last line says crontab is valid, everything is ok."
echo "The errors are because it tries to parse each crontab entry with both 5 and 6 fields."
/usr/local/bin/supercronic -debug -test "${cron_file}" || {
  echo "ERROR: crontab file is invalid"
  exit 1
}

/usr/local/bin/supercronic "${cron_file}"

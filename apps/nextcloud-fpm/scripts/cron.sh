#!/bin/sh
set -e

# Wait for Nextcloud installation to complete
while [ ! -f "/var/www/html/lib/versioncheck.php" ]; do
  echo 'Waiting for Nextcloud installation to complete...'
  echo 'Checking again in 2 minutes...'
  sleep 2m
done

cron_file="${CRON_TAB_FILE:-/crontasks}"

# Test crontab file
echo "Testing crontab file: ${cron_file}"
echo "NOTE: You may see parsing errors below, which is normal."
echo "Supercronic tests each entry as both 5-field (standard) and 6-field formats."
echo "If the final message shows 'crontab is valid', your configuration is correct."

# Validate crontab
/usr/local/bin/supercronic -debug -test "${cron_file}" || {
  echo "ERROR: Crontab validation failed. Please check your syntax."
  exit 1
}

echo "Crontab validation successful. Starting supercronic service..."
/usr/local/bin/supercronic "${cron_file}"

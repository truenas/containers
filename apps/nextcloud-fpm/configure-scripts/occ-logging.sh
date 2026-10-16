#!/bin/sh
occ_logging() {
  echo '## Configuring Logging...'
  echo ''

  log_file="${IX_LOG_FILE:-"/var/www/html/data/nextcloud.log"}"
  log_file_audit="${IX_LOG_FILE_AUDIT:-"/var/www/html/data/audit.log"}"

  # Nextcloud does not create the log directory. When it is missing, it silently
  # logs to <datadirectory>/nextcloud.log instead, and the log rotation job only
  # looks at the configured path, so that fallback log grows forever.
  for dir in "$(dirname "$log_file")" "$(dirname "$log_file_audit")"; do
    mkdir -p "$dir" || echo "Failed to create log directory [$dir]. Continuing..."
  done

  occ config:system:set log_type --value="file"
  occ config:system:set log_type_audit --value="file"
  occ config:system:set loglevel --value="${IX_LOG_LEVEL:-2}"
  occ config:system:set logfile --value="$log_file"
  occ config:system:set logfile_audit --value="$log_file_audit"
  occ config:system:set logdateformat --value="${IX_LOG_DATE_FORMAT:-"d/m/Y H:i:s"}"
  occ config:system:set logtimezone --value="${IX_LOG_TIMEZONE:-$TZ}"
}

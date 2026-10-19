#!/bin/sh

occ_database() {
  echo '## Configuring Database...'
  echo ''

  config_file="${IX_CONFIG_FILE_PATH:-/var/www/html/config/config.php}"

  if [ ! -f "$config_file" ]; then
    echo "Config file $config_file does not exist. Something is wrong."
    exit 1
  fi

  echo "Using an inline php script to update the database config instead of occ..."
  echo "Reason: https://github.com/nextcloud/server/issues/44924"

  run_php /configure-scripts/config-set.php "${config_file}" \
    dbtype 'pgsql' \
    dbhost "${IX_POSTGRES_HOST:?"IX_POSTGRES_HOST is unset"}" \
    dbname "${IX_POSTGRES_NAME:?"IX_POSTGRES_NAME is unset"}" \
    dbuser "${IX_POSTGRES_USER:?"IX_POSTGRES_USER is unset"}" \
    dbpassword "${IX_POSTGRES_PASSWORD:?"IX_POSTGRES_PASSWORD is unset"}" \
    dbport "${IX_POSTGRES_PORT:-5432}"

  # occ config:system:set dbtype --value="pgsql"
  # occ config:system:set dbhost --value="${IX_POSTGRES_HOST:?"IX_POSTGRES_HOST is unset"}"
  # occ config:system:set dbname --value="${IX_POSTGRES_NAME:?"IX_POSTGRES_NAME is unset"}"
  # occ config:system:set dbuser --value="${IX_POSTGRES_USER:?"IX_POSTGRES_USER is unset"}"
  # occ config:system:set dbpassword --value="${IX_POSTGRES_PASSWORD:?"IX_POSTGRES_PASSWORD is unset"}"
  # occ config:system:set dbport --value="${IX_POSTGRES_PORT:-5432}"
}

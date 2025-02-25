#!/bin/sh
occ_database() {
  echo '## Configuring Database...'

  occ config:system:set dbtype --value="pgsql"
  occ config:system:set dbhost --value="${IX_POSTGRES_HOST:?"IX_POSTGRES_HOST is unset"}"
  occ config:system:set dbname --value="${IX_POSTGRES_NAME:?"IX_POSTGRES_NAME is unset"}"
  occ config:system:set dbuser --value="${IX_POSTGRES_USER:?"IX_POSTGRES_USER is unset"}"
  occ config:system:set dbpassword --value="${IX_POSTGRES_PASSWORD:?"IX_POSTGRES_PASSWORD is unset"}"
  occ config:system:set dbport --value="${IX_POSTGRES_PORT:-5432}"
}

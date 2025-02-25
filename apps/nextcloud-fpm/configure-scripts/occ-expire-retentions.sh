#!/bin/sh
occ_expire_retention() {
  echo '## Configuring Expiring and Retention Days...'
  occ config:system:set activity_expire_days --value="${IX_ACTIVITY_EXPIRE_DAYS:-90}" --type=integer
  occ config:system:set trashbin_retention_obligation --value="${IX_TRASH_RETENTION:-auto}"
  occ config:system:set versions_retention_obligation --value="${IX_VERSIONS_RETENTION:-auto}"
}

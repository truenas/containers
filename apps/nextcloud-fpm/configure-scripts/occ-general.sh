#!/bin/sh
occ_general() {
  echo "## Configuring General Settings..."
  echo ''

  echo '### Disabling WebUI Updater...'
  occ config:system:set upgrade.disable-web --type=bool --value=true

  echo '### Configuring Default Phone Region...'
  occ config:system:set default_phone_region --value="${IX_DEFAULT_PHONE_REGION:-GR}"

  echo '### Configuring "Shared" folder...'
  occ config:system:set share_folder --value="${IX_SHARED_FOLDER_NAME:-/}"

  echo '### Configuring Max Chunk Size for Files...'
  # Since Nextcloud 31 the chunk size is read from the system config key,
  # the legacy "files/max_chunk_size" app config key is no longer used.
  occ config:system:set files.chunked_upload.max_size --type=integer --value="${IX_MAX_CHUNKSIZE:-10485760}"
  occ config:app:delete files max_chunk_size

  echo '### Configuring Maintenance Window Start...'
  occ config:system:set maintenance_window_start --type=integer --value="${IX_MAINTENANCE_WINDOW_START:-100}"
}

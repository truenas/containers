#!/bin/sh
occ_general() {
  echo '## Disabling WebUI Updater...'
  occ config:system:set upgrade.disable-web --type=bool --value=true

  echo '## Configuring Default Phone Region...'
  occ config:system:set default_phone_region --value=${IX_DEFAULT_PHONE_REGION:-GR}

  echo '## Configuring "Shared" folder...'
  occ config:system:set share_folder --value="${IX_SHARED_FOLDER_NAME:-/}"

  echo '## Configuring Max Chunk Size for Files...'
  occ config:app:set files max_chunk_size --value="${IX_MAX_CHUNKSIZE:-10485760}"

  echo '## Configuring Maintenance Window Start...'
  occ config:system:set maintenance_window_start --type=integer --value="${IX_MAINTENANCE_WINDOW_START:-100}"
}

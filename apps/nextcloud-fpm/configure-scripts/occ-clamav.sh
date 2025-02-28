#!/bin/sh
occ_clamav_install() {
  echo '## Configuring ClamAV...'
  echo ''

  install_app files_antivirus

  occ config:app:set files_antivirus av_mode --value="daemon"
  occ config:app:set files_antivirus av_host --value="${IX_CLAMAV_HOST:?"IX_CLAMAV_HOST is unset"}"
  occ config:app:set files_antivirus av_port --value="${IX_CLAMAV_PORT:-3310}"
  occ config:app:set files_antivirus av_stream_max_length --value="${IX_CLAMAV_STREAM_MAX_LENGTH:-26214400}"
  occ config:app:set files_antivirus av_max_file_size --value="${IX_CLAMAV_MAX_FILE_SIZE:-"-1"}"
  occ config:app:set files_antivirus av_infected_action --value="${IX_CLAMAV_INFECTED_ACTION:-"only_log"}"
}

occ_clamav_remove() {
  echo '## Removing ClamAV Configuration...'
  echo ''

  remove_app files_antivirus

  occ config:app:delete files_antivirus av_mode
  occ config:app:delete files_antivirus av_host
  occ config:app:delete files_antivirus av_port
  occ config:app:delete files_antivirus av_stream_max_length
  occ config:app:delete files_antivirus av_max_file_size
  occ config:app:delete files_antivirus av_infected_action
}

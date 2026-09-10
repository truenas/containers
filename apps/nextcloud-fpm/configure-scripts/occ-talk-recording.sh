#!/bin/sh
occ_talk_recording_install() {
  echo '## Configuring Talk Recording...'
  echo ''

  : "${IX_TALK_RECORDING_SERVER:?"IX_TALK_RECORDING_SERVER is unset"}"
  : "${IX_TALK_RECORDING_SECRET:?"IX_TALK_RECORDING_SECRET is unset"}"

  # Recording is part of the talk (spreed) app, there is no separate app to install.
  # Note this is stored as an array, unlike the signaling servers which are a string.
  echo '### Configuring Talk Recording server...'
  set_app_value spreed recording_servers array "$(
    IX_TALK_RECORDING_SERVER_VERIFY="${IX_TALK_RECORDING_SERVER_VERIFY:-"true"}" \
      yq -n -o=json -I=0 '{
        "servers": [{
          "server": strenv(IX_TALK_RECORDING_SERVER),
          "verify": (strenv(IX_TALK_RECORDING_SERVER_VERIFY) == "true")
        }],
        "secret": strenv(IX_TALK_RECORDING_SECRET)
      }'
  )"
}

occ_talk_recording_remove() {
  echo '## Removing Talk Recording Configuration...'
  echo ''

  occ config:app:delete spreed recording_servers
}

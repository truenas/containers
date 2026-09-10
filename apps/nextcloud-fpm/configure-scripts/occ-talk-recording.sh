#!/bin/sh
occ_talk_recording_install() {
  echo '## Configuring Talk Recording...'
  echo ''

  : "${IX_TALK_RECORDING_SERVER:?"IX_TALK_RECORDING_SERVER is unset"}"
  : "${IX_TALK_RECORDING_SECRET:?"IX_TALK_RECORDING_SECRET is unset"}"

  # Recording is part of the talk (spreed) app, there is no separate app to install.

  # Defaults to yes and is not exposed in the admin UI, but if it has ever been set
  # to no, nextcloud stops advertising the recording capability and the container
  # sits there healthy and idle with no indication why.
  echo '### Enabling call recording...'
  set_app_value spreed call_recording string yes

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

  # Deleting call_recording puts it back to its default of yes, which is fine.
  # Without any recording servers, nextcloud reports recording as disabled anyway.
  occ config:app:delete spreed call_recording
  occ config:app:delete spreed recording_servers
}

#!/bin/sh
occ_talk_install() {
  echo '## Configuring Talk...'
  echo ''

  : "${IX_TALK_STUN_SERVERS:?"IX_TALK_STUN_SERVERS is unset"}"
  : "${IX_TALK_TURN_SERVERS:?"IX_TALK_TURN_SERVERS is unset"}"
  : "${IX_TALK_SIGNALING_SERVER:?"IX_TALK_SIGNALING_SERVER is unset"}"
  : "${IX_TALK_SIGNALING_SECRET:?"IX_TALK_SIGNALING_SECRET is unset"}"

  install_app spreed

  # These are written in full on every start, so what is configured on the app
  # is exactly what ends up here. Servers added through the nextcloud admin UI
  # are replaced, extra ones belong in the app configuration instead.
  #
  # Note also that `talk:stun:add`, `talk:turn:add` and `talk:signaling:add` are
  # not re-runnable. The first two exit 1 when the entry already exists (which
  # would abort this script), and the last appends a duplicate on every run.
  echo '### Configuring Talk STUN servers...'
  set_app_value spreed stun_servers "$(
    TALK_STUN_SERVERS=$(echo "$IX_TALK_STUN_SERVERS" | tr '\n' ' ') \
      yq -n -o=json -I=0 '[strenv(TALK_STUN_SERVERS) | split(" ") | .[] | select(. != "")]'
  )"

  # Already a json array, each entry holding its own schemes/server/secret/protocols
  echo '### Configuring Talk TURN servers...'
  set_app_value spreed turn_servers "$(printf '%s' "$IX_TALK_TURN_SERVERS" | yq -p=json -o=json -I=0 '.')"

  # Merged rather than replaced, this one is an object and may hold keys we do
  # not manage. The stun and turn values above are plain arrays, nothing to keep.
  echo '### Configuring Talk Signaling server...'
  merge_app_value spreed signaling_servers "$(
    IX_TALK_SIGNALING_SERVER_VERIFY="${IX_TALK_SIGNALING_SERVER_VERIFY:-"true"}" \
      yq -n -o=json -I=0 '{
        "servers": [{
          "server": strenv(IX_TALK_SIGNALING_SERVER),
          "verify": (strenv(IX_TALK_SIGNALING_SERVER_VERIFY) == "true")
        }],
        "secret": strenv(IX_TALK_SIGNALING_SECRET)
      }'
  )"
}

occ_talk_remove() {
  echo '## Removing Talk Configuration...'
  echo ''

  remove_app spreed

  occ config:app:delete spreed stun_servers
  occ config:app:delete spreed turn_servers
  occ config:app:delete spreed signaling_servers
}

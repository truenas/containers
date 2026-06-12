#!/bin/sh
occ_talk_install() {
  echo '## Configuring Talk...'
  echo ''

  install_app spreed

  # ie "stun1:3478 stun2:3478"
  occ config:app:delete spreed stun_servers
  for stun_server in ${IX_TALK_STUN_SERVER:?"IX_TALK_STUN_SERVER is unset"}; do
    occ talk:stun:add "$stun_server"
  done

  occ config:app:delete spreed turn_servers
  occ talk:turn:add turn "${IX_TALK_TURN_SERVER:?"IX_TALK_TURN_SERVER is unset"}" "udp,tcp" --secret="${IX_TALK_TURN_SECRET:?"IX_TALK_TURN_SECRET is unset"}"

  sig_verify=""
  [ "${IX_TALK_SIGNALING_SERVER_VERIFY:-true}" = "true" ] && sig_verify="--verify"
  occ config:app:delete spreed signaling_servers
  occ talk:signaling:add "https://${IX_TALK_SIGNALING_SERVER:?"IX_TALK_SIGNALING_SERVER is unset"}" "${IX_TALK_SIGNALING_SECRET:?"IX_TALK_SIGNALING_SECRET is unset"}" $sig_verify
}

occ_talk_remove() {
  echo '## Removing Talk Configuration...'
  echo ''

  remove_app spreed
  occ config:app:delete spreed turn_servers
  occ config:app:delete spreed stun_servers
  occ config:app:delete spreed signaling_servers
}

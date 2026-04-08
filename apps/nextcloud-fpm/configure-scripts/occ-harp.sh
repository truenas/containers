#!/bin/sh
. /configure-scripts/helpers.sh

occ_harp_install() {
  echo '## Configuring HaRP (AppAPI)...'
  install_app app_api

  if occ app_api:daemon:get harp >/dev/null 2>&1; then
    occ app_api:daemon:update harp \
      --net "${IX_HARP_NETWORK}" --harp \
      --harp_frp_address "${IX_HARP_FRP_ADDRESS}" \
      --harp_shared_key "${IX_HARP_SHARED_KEY}" \
      || echo 'Daemon update failed. Skipping...'
  else
    occ app_api:daemon:register harp "HaRP (TrueNAS)" "docker-install" "http" \
      "${IX_HARP_URL}" "${IX_HARP_NC_URL}" \
      --net "${IX_HARP_NETWORK}" --harp \
      --harp_frp_address "${IX_HARP_FRP_ADDRESS}" \
      --harp_shared_key "${IX_HARP_SHARED_KEY}" \
      --set-default \
      || echo 'Daemon registration failed.'
  fi
}

occ_harp_remove() {
  echo '## Removing HaRP (AppAPI) configuration...'
  occ app_api:daemon:get harp >/dev/null 2>&1 && \
    occ app_api:daemon:unregister harp || true
  remove_app app_api
}

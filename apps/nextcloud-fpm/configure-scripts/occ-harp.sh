#!/bin/sh
occ_harp_install() {
  echo '## Configuring HaRP (AppAPI)...'
  echo ''

  install_app app_api

  if occ app_api:daemon:get harp >/dev/null 2>&1; then
    occ app_api:daemon:update harp \
      --net "${IX_HARP_NETWORK:?"IX_HARP_NETWORK is unset"}" --harp \
      --harp_frp_address "${IX_HARP_FRP_ADDRESS:?"IX_HARP_FRP_ADDRESS is unset"}" \
      --harp_shared_key "${IX_HARP_SHARED_KEY:?"IX_HARP_SHARED_KEY is unset"}"
  else
    occ app_api:daemon:register harp "HaRP (TrueNAS)" "docker-install" "http" \
      "${IX_HARP_URL:?"IX_HARP_URL is unset"}" "${IX_HARP_NC_URL:?"IX_HARP_NC_URL is unset"}" \
      --net "${IX_HARP_NETWORK:?"IX_HARP_NETWORK is unset"}" --harp \
      --harp_frp_address "${IX_HARP_FRP_ADDRESS:?"IX_HARP_FRP_ADDRESS is unset"}" \
      --harp_shared_key "${IX_HARP_SHARED_KEY:?"IX_HARP_SHARED_KEY is unset"}" \
      --set-default
  fi
}

occ_harp_remove() {
  echo '## Removing HaRP (AppAPI) configuration...'
  echo ''

  if occ app_api:daemon:get harp >/dev/null 2>&1; then
    occ app_api:daemon:unregister harp
  fi

  remove_app app_api
}

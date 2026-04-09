#!/bin/sh
occ_harp_install() {
  echo '## Configuring HaRP (AppAPI)...'
  echo ''

  install_app app_api

  if occ app_api:daemon:list | grep -q '| tn-harp '; then
    occ app_api:daemon:unregister tn-harp
  fi

  occ app_api:daemon:register tn-harp "HaRP (TrueNAS)" "docker-install" "http" \
    "${IX_HARP_INTERNAL_URL:?"IX_HARP_INTERNAL_URL is unset"}" "${IX_HARP_NC_INTERNAL_URL:?"IX_HARP_NC_INTERNAL_URL is unset"}" \
    --net="${IX_HARP_NETWORK:?"IX_HARP_NETWORK is unset"}" \
    --harp_frp_address="${IX_HARP_INTERNAL_FRP_ADDRESS:?"IX_HARP_INTERNAL_FRP_ADDRESS is unset"}" \
    --harp_shared_key="${IX_HARP_SHARED_KEY:?"IX_HARP_SHARED_KEY is unset"}" \
    --harp \
    --set-default
}

occ_harp_remove() {
  echo '## Removing HaRP (AppAPI) configuration...'
  echo ''

  if occ app_api:daemon:list | grep -q '| tn-harp '; then
    occ app_api:daemon:unregister tn-harp
  fi

  remove_app app_api
}

#!/bin/sh
occ_harp_install() {
  echo '## Configuring HaRP (AppAPI)...'
  echo ''

  install_app app_api

  case "${IX_HARP_COMPUTE_DEVICE:=cpu}" in
    cpu|cuda|rocm) ;;
    *) echo "ERROR: IX_HARP_COMPUTE_DEVICE must be cpu, cuda, or rocm (got: ${IX_HARP_COMPUTE_DEVICE})"; exit 1 ;;
  esac

  if occ app_api:daemon:list | grep -q '| tn-harp '; then
    occ app_api:daemon:unregister tn-harp
  fi

  occ app_api:daemon:register tn-harp "HaRP (TrueNAS)" "docker-install" "http" \
    "${IX_HARP_INTERNAL_URL:?"IX_HARP_INTERNAL_URL is unset"}" "${IX_HARP_NC_INTERNAL_URL:?"IX_HARP_NC_INTERNAL_URL is unset"}" \
    --net="${IX_HARP_NETWORK:?"IX_HARP_NETWORK is unset"}" \
    --harp_frp_address="${IX_HARP_INTERNAL_FRP_ADDRESS:?"IX_HARP_INTERNAL_FRP_ADDRESS is unset"}" \
    --harp_shared_key="${IX_HARP_SHARED_KEY:?"IX_HARP_SHARED_KEY is unset"}" \
    --compute_device="${IX_HARP_COMPUTE_DEVICE}" \
    --harp \
    --set-default
}

occ_harp_remove() {
  echo '## Removing HaRP (AppAPI) configuration...'
  echo ''

  # Can't remove the app because it's a built-in app.
  # Just cleanup the daemon registration if it exists.

  if occ app_api:daemon:list | grep -q '| tn-harp '; then
    occ app_api:daemon:unregister tn-harp
  fi
}

#!/bin/sh

harp_daemon_exists() {
  name="${1:?"name is unset"}"

  occ app_api:daemon:list | grep -q "| $name "
}

harp_daemon_register() {
  name="${1:?"name is unset"}"
  shift

  occ app_api:daemon:register "$name" "HaRP (TrueNAS)" "docker-install" "http" \
    "${IX_HARP_INTERNAL_ADDRESS:?"IX_HARP_INTERNAL_ADDRESS is unset"}" "${IX_HARP_NC_INTERNAL_URL:?"IX_HARP_NC_INTERNAL_URL is unset"}" \
    --net="${IX_HARP_NETWORK:?"IX_HARP_NETWORK is unset"}" \
    --harp_frp_address="${IX_HARP_INTERNAL_FRP_ADDRESS:?"IX_HARP_INTERNAL_FRP_ADDRESS is unset"}" \
    --harp_shared_key="${IX_HARP_SHARED_KEY:?"IX_HARP_SHARED_KEY is unset"}" \
    --compute_device="${IX_HARP_COMPUTE_DEVICE}" \
    --harp \
    "$@"
}

occ_harp_install() {
  echo '## Configuring HaRP (AppAPI)...'
  echo ''

  install_app app_api

  case "${IX_HARP_COMPUTE_DEVICE:=cpu}" in
    cpu|cuda|rocm) ;;
    *) echo "ERROR: IX_HARP_COMPUTE_DEVICE must be cpu, cuda, or rocm (got: ${IX_HARP_COMPUTE_DEVICE})"; exit 1 ;;
  esac

  # Left over from a startup that failed halfway through patching
  if harp_daemon_exists tn-harp-staging; then
    occ app_api:daemon:unregister tn-harp-staging
  fi

  if ! harp_daemon_exists tn-harp; then
    harp_daemon_register tn-harp --set-default
    return 0
  fi

  # AppAPI refuses to unregister a daemon that has ExApps deployed on it, and has
  # no occ command to update one. So register the settings under a staging name
  # and patch them onto the existing daemon in place.
  # Upstream request for an occ command: https://github.com/nextcloud/app_api/issues/1129
  harp_daemon_register tn-harp-staging
  run_php /configure-scripts/harp-daemon-patch.php tn-harp tn-harp-staging
}

occ_harp_remove() {
  echo '## Removing HaRP (AppAPI) configuration...'
  echo ''

  # Can't remove the app because it's a built-in app.
  # Just cleanup the daemon registration if it exists.

  if ! harp_daemon_exists tn-harp; then
    return 0
  fi

  # AppAPI refuses to unregister a daemon that has ExApps deployed on it.
  # Keep the registration then, instead of failing the startup.
  rc=0
  output=$(occ app_api:daemon:unregister tn-harp) || rc=$?
  echo "$output"

  if [ "$rc" = 0 ]; then
    return 0
  fi

  if ! echo "$output" | grep -q 'ExApps, please remove them first'; then
    exit 1
  fi

  echo 'WARNING: Keeping the tn-harp daemon registration, remove its ExApps to have it unregistered.'
}

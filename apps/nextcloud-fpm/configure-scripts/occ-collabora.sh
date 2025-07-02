#!/bin/sh
occ_collabora_install() {
  echo '## Configuring Collabora...'
  echo ''

  install_app richdocuments

  occ config:app:set richdocuments wopi_url --value="${IX_COLLABORA_INTERNAL_URL:?"IX_COLLABORA_INTERNAL_URL is unset"}"
  occ config:app:set richdocuments public_wopi_url --value="${IX_COLLABORA_URL:?"IX_COLLABORA_URL is unset"}"
  occ config:app:set richdocuments wopi_allowlist --value="${IX_COLLABORA_ALLOWLIST:?"IX_COLLABORA_ALLOWLIST is unset"}"
}

occ_collabora_remove() {
  echo '## Removing Collabora Configuration...'
  echo ''

  remove_app richdocuments

  occ config:app:delete richdocuments wopi_url
  occ config:app:delete richdocuments public_wopi_url
  occ config:app:delete richdocuments wopi_allowlist
}

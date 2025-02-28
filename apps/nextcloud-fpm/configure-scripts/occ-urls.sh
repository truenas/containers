#!/bin/sh
occ_urls() {
  echo "## Configuring URLs..."
  echo ''

  echo '### Configuring Overwrite URLs...'
  occ config:system:set overwrite.cli.url --value="${IX_OVERWRITE_CLI_URL:?"IX_OVERWRITE_CLI_URL is unset"}"
  occ config:system:set overwritehost --value="${IX_OVERWRITE_HOST:?"IX_OVERWRITE_HOST is unset"}"
  occ config:system:set overwriteprotocol --value="${IX_OVERWRITE_PROTOCOL:?"IX_OVERWRITE_PROTOCOL is unset"}"

  echo '### Configuring Trusted Domains...'
  [ "${IX_TRUSTED_DOMAINS:?"IX_TRUSTED_DOMAINS is unset"}" ]

  # If Collabora is enabled, add Collabora URL to trusted domains
  if [ "${IX_COLLABORA:-"false"}" = "true" ]; then
    [ "${IX_COLLABORA_URL:?"IX_COLLABORA_URL is unset"}" ]
    IX_COLLABORA_DOMAIN=$(extract_domain "$IX_COLLABORA_URL")
    if [ "${IX_COLLABORA_DOMAIN}" != "${IX_OVERWRITE_HOST}" ]; then
      IX_TRUSTED_DOMAINS="${IX_TRUSTED_DOMAINS} ${IX_COLLABORA_DOMAIN}"
    fi
  fi

  # If OnlyOffice is enabled, add OnlyOffice URL to trusted domains
  if [ "${IX_ONLYOFFICE:-"false"}" = "true" ]; then
    [ "${IX_ONLYOFFICE_URL:?"IX_ONLYOFFICE_URL is unset"}" ]
    IX_ONLYOFFICE_DOMAIN=$(extract_domain "$IX_ONLYOFFICE_URL")
    if [ "${IX_ONLYOFFICE_DOMAIN}" != "${IX_OVERWRITE_HOST}" ]; then
      IX_TRUSTED_DOMAINS="${IX_TRUSTED_DOMAINS} ${IX_ONLYOFFICE_DOMAIN}"
    fi
  fi

  set_list 'trusted_domains' "${IX_TRUSTED_DOMAINS}" 'system'

  echo '### Configuring Trusted Proxies...'
  set_list 'trusted_proxies' "${IX_TRUSTED_PROXIES:?"IX_TRUSTED_PROXIES is unsed"}" 'system'
}

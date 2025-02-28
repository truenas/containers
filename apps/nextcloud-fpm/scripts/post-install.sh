#!/bin/sh
set -e

echo '++++++++++++++++++++++++++++++++++++++++++++++++++'
echo ''
### Source all configure-scripts. ###
for script in /configure-scripts/*.sh; do
  echo "Sourcing $script"
  # shellcheck disable=SC1090
  . "$script"
done

echo ''
echo 'Executing injected scripts...'
echo '++++++++++++++++++++++++++++++++++++++++++++++++++'
echo ''

### Start Configuring ###
# Configure Database
echo ''
occ_database

# Configure Redis
if [ "${IX_REDIS:-"true"}" = "true" ]; then
  echo '# Redis is enabled.'
  occ_redis_install
else
  echo '# Redis is disabled.'
  occ_redis_remove
fi

echo ''
# Configure General Settings
occ_general

echo ''
# Configure Logging
occ_logging

echo ''
# Configure URLs (Trusted Domains, Trusted Proxies, Overwrites, etc)
occ_urls

echo ''
# Configure Expiration/Retention Days
occ_expire_retention

echo ''
# Configure Notify Push
if [ "${IX_NOTIFY_PUSH:-"true"}" = "true" ]; then
  echo '# Notify Push is enabled.'
  occ_notify_push_install
else
  echo '# Notify Push is disabled.'
  occ_notify_push_remove
fi

echo ''
# If Imaginary is enabled, previews are forced enabled
if [ "${IX_IMAGINARY:-"true"}" = "true" ]; then
  IX_PREVIEWS="true"
  echo '# Imaginary is enabled.'
  occ_imaginary_install
else
  echo '# Imaginary is disabled.'
  occ_imaginary_remove
fi

echo ''
# If Imaginary is disabled but previews are enabled, configure only previews
if [ "${IX_PREVIEWS:-"true"}" = "true" ]; then
  echo '# Preview Generator is enabled.'
  occ_preview_generator_install
else
  echo '# Preview Generator is disabled.'
  occ_preview_generator_remove
fi

echo ''
# Configure ClamAV
if [ "${IX_CLAMAV:-"false"}" = "true" ]; then
  echo '# ClamAV is enabled.'
  occ_clamav_install
else
  echo '# ClamAV is disabled.'
  occ_clamav_remove
fi

echo ''
# Configure Collabora
if [ "${IX_COLLABORA:-"false"}" = "true" ]; then
  echo '# Collabora is enabled.'
  occ_collabora_install
else
  echo '# Collabora is disabled.'
  occ_collabora_remove
fi

echo ''
# Configure OnlyOffice
if [ "${IX_ONLYOFFICE:-"false"}" = "true" ]; then
  echo '# OnlyOffice is enabled.'
  occ_onlyoffice_install
else
  echo '# OnlyOffice is disabled.'
  occ_onlyoffice_remove
fi

if [ "${IX_ONLYOFFICE:-"false"}" = "true" ] || [ "${IX_COLLABORA:-"false"}" = "true" ]; then
  occ config:system:set allow_local_remote_servers --value="true"
else
  occ config:system:delete allow_local_remote_servers
fi

echo ''
# Perform cleanups
occ_cleanups

echo ''
echo '++++++++++++++++++++++++++++++++++++++++++++++++++'
### End Configuring ###

echo '--------------------------------------------------'
echo ''

# Run optimize/repairs/migrations
if [ "${IX_RUN_OPTIMIZE:-"true"}" = "true" ]; then
  echo '# Optimize is enabled. Running...'
  occ_optimize
else
  echo '# Optimize is disabled. Skipping...'
fi

echo ''
echo '--------------------------------------------------'

echo 'Starting Nextcloud PHP-FPM'

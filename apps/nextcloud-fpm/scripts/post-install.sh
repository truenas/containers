#!/bin/sh

echo '++++++++++++++++++++++++++++++++++++++++++++++++++'
echo ''
### Source all configure-scripts. ###
for script in /configure-scripts/*.sh; do
  echo "Sourcing $script"
  . "$script"
done

echo ''
echo 'Executing injected scripts...'
echo '++++++++++++++++++++++++++++++++++++++++++++++++++'
echo ''

### Start Configuring ###

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
if [ "${IX_CLAMAV:-"false"}" = "true" ]; then
  echo '# ClamAV is enabled.'
  occ_clamav_install
else
  echo '# ClamAV is disabled.'
  occ_clamav_remove
fi

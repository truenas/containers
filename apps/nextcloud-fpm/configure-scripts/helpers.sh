#!/bin/sh

# Installs the passed application if not already installed
install_app() {
  app_name="${1:?"app_name is unset"}"

  echo "Installing [$app_name]..."

  disabled_apps=$(occ app:list | yq '.Disabled')
  if echo "$disabled_apps" | grep -wq "$app_name"; then
    echo "App [$app_name] is installed but disabled! Enabling..."
    occ app:enable "$app_name"
    return 0
  fi

  enabled_apps=$(occ app:list | yq '.Enabled')
  if echo "$enabled_apps" | grep -wq "$app_name"; then
    echo "App [$app_name] is installed and enabled! Skipping..."
    return 0
  fi

  # Here the app is not installed and we need to install it
  if ! occ app:install "$app_name"; then
    echo "Failed to install $app_name..."
    exit 1
  fi

  echo "App [$app_name] installed successfully!"
}

remove_app() {
  app_name="${1:?"app_name is unset"}"

  echo "Removing [$app_name]..."

  disabled_apps=$(occ app:list | yq '.Disabled')
  if echo "$disabled_apps" | grep -wq "$app_name"; then
    echo "App [$app_name] is disabled! Enabling temporarily to remove..."
    echo "Reason: https://github.com/nextcloud/server/issues/49689"
    occ app:enable "$app_name"
  fi

  # Here the app is either enabled or not installed. Skip if not installed
  enabled_apps=$(occ app:list | yq '.Enabled')
  if ! echo "$enabled_apps" | grep -wq "$app_name"; then
    echo "App [$app_name] is not installed! Skipping..."
    return 0
  fi

  # Here the app is installed and enabled. Remove it
  if ! occ app:remove "$app_name"; then
    echo "Failed to remove [$app_name]..."
    exit 1
  fi

  echo "App [$app_name] removed successfully!"
}

# Sets a space separated values into the specified list, by default for system settings
# Pass a 3rd argument for a different app
set_list() {
  list_name="${1:?"list_name is unset"}"
  space_delimited_values="${2:?"space_delimited_values is unset"}"
  app="${3:-"system"}"
  prefix="${4:-""}"

  if [ -n "${space_delimited_values}" ]; then

    if [ "${app}" != 'system' ]; then
      occ config:app:delete "$app" "$list_name"
    else
      occ config:system:delete "$list_name"
    fi

    IDX=0
    # Replace spaces with newlines so the input can have
    # mixed entries of space or new line separated values
    echo "$space_delimited_values" | tr ' ' '\n' | while IFS= read -r value; do
      # Skip empty values
      if [ -z "$value" ]; then
        continue
      fi

      # Prepend prefix (eg OC\Preview)
      if [ -n "${prefix}" ]; then
        value="$prefix$value"
      fi

      if [ "${app}" != 'system' ]; then
        occ config:app:set "$app" "$list_name" $IDX --value="$value"
      else
        occ config:system:set "$list_name" $IDX --value="$value"
      fi

      IDX=$((IDX + 1))
    done
  fi
}

# Replaces an app config key with the given value.
#
# No --type is passed on purpose. It stores the value as `mixed`, which is what
# nextcloud's own writers produce. Giving it a concrete type makes every later
# write from nextcloud itself fail with "conflict between new type (mixed) and
# old type (...)", which breaks both the `occ` commands and the admin UI.
#
# The key is deleted first so a value stored with a concrete type by an earlier
# version of this script gets reset back to mixed.
set_app_value() {
  app="${1:?"app is unset"}"
  key="${2:?"key is unset"}"
  value="${3:?"value is unset"}"

  occ config:app:delete "$app" "$key"
  occ config:app:set "$app" "$key" --value="$value"
}

# Merges a JSON object into an app config key that holds a JSON object.
#
# `config:app:set` only takes a whole value, there is no nested key support for
# app config (unlike system config), so the entire value has to be rewritten.
# Merging first means keys we do not manage are carried over instead of dropped,
# in case nextcloud grows another key inside one of these objects.
#
# Anything that is not a JSON object (unset, empty, corrupted) is treated as an
# empty object, so a bad value gets replaced rather than failing the startup.
merge_app_value() {
  app="${1:?"app is unset"}"
  key="${2:?"key is unset"}"
  value="${3:?"value is unset"}"

  current=$(occ config:app:get "$app" "$key" 2>/dev/null) || current=""
  if [ -z "$current" ] || [ "$(printf '%s' "$current" | yq -p=json -o=json 'type' 2>/dev/null)" != '"!!map"' ]; then
    current='{}'
  fi

  merged=$(CURRENT="$current" NEW="$value" yq -n -o=json -I=0 '(strenv(CURRENT) | from_json) * (strenv(NEW) | from_json)')
  set_app_value "$app" "$key" "$merged"
}

extract_domain() {
  url="$1"

  # Remove http(s):// from URL
  domain="${url#*://}"

  # Remove /foo (subfolder) from domain
  domain="${domain%%/*}"

  echo "$domain"
}

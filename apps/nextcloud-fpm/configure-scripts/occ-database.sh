#!/bin/sh

# Note that this assumes:
# - Key is top-level key in config.php
# - Value is always a string
update_db_config() {
  key="$1"
  value="$2"
  filepath="$3"

  # We Base64 encode and decode the value to safely handle special characters
  php <<EOF
  <?php
    \$key = '$key';
    \$value = '$value';
    \$filepath = '$filepath';

    \$encoded_value = base64_decode('$(printf "%s" "$value" | base64)');

    include(\$filepath);
    \$CONFIG[\$key] = (string)\$encoded_value;
    file_put_contents(\$filepath, "<?php\n\\\$CONFIG = ".var_export(\$CONFIG, true).";\n");
EOF
}

occ_database() {
  echo '## Configuring Database...'

  config_file="${IX_CONFIG_FILE_PATH:-/var/www/html/config/config.php}"

  if [ ! -f "$config_file" ]; then
    echo "Config file $config_file does not exist. Something is wrong."
    exit 1
  fi

  update_db_config 'dbtype' 'pgsql' "${config_file}"
  update_db_config 'dbhost' "${IX_POSTGRES_HOST:?"IX_POSTGRES_HOST is unset"}" "${config_file}"
  update_db_config 'dbname' "${IX_POSTGRES_NAME:?"IX_POSTGRES_NAME is unset"}" "${config_file}"
  update_db_config 'dbuser' "${IX_POSTGRES_USER:?"IX_POSTGRES_USER is unset"}" "${config_file}"
  update_db_config 'dbpassword' "${IX_POSTGRES_PASSWORD:?"IX_POSTGRES_PASSWORD is unset"}" "${config_file}"
  update_db_config 'dbport' "${IX_POSTGRES_PORT:-5432}" "${config_file}"

  # - https://github.com/nextcloud/server/issues/44924
  # Due to a bug in Nextcloud, you cannot use `occ` to update the db config if you are not connected to the database.

  # occ config:system:set dbtype --value="pgsql"
  # occ config:system:set dbhost --value="${IX_POSTGRES_HOST:?"IX_POSTGRES_HOST is unset"}"
  # occ config:system:set dbname --value="${IX_POSTGRES_NAME:?"IX_POSTGRES_NAME is unset"}"
  # occ config:system:set dbuser --value="${IX_POSTGRES_USER:?"IX_POSTGRES_USER is unset"}"
  # occ config:system:set dbpassword --value="${IX_POSTGRES_PASSWORD:?"IX_POSTGRES_PASSWORD is unset"}"
  # occ config:system:set dbport --value="${IX_POSTGRES_PORT:-5432}"
}

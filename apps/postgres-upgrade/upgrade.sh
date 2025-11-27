#!/bin/bash
set -euo pipefail

# Source the upstream entrypoint to get docker_init_database_dir and other functions
source /usr/local/bin/docker-entrypoint.sh

# Mount Point
BASE_DIR="/var/lib/postgresql"

get_bin_path() {
  local version=$1
  echo "/usr/lib/postgresql/$version/bin"
}

log() {
  echo "[ix-postgres-main]      - [$(date +'%Y-%m-%d %H:%M:%S')] - $1" >&2
}

up_log() {
  echo "[ix-postgres-upgrade]   - [$(date +'%Y-%m-%d %H:%M:%S')] - $1" >&2
}

dm_log() {
  echo "[ix-postgres-directory] - [$(date +'%Y-%m-%d %H:%M:%S')] - $1" >&2
}

empty_line() {
  echo ""; echo ""
}

check_same_filesystem() {
  local old_location="$1"
  local new_location="$2"

  if [ "$(stat -c '%d' "$old_location")" != "$(stat -c '%d' "$new_location")" ]; then
    log "Error: Old location [$old_location] and new location [$new_location] are on different filesystems."
    return 1
  fi
  return 0
}

check_writable() {
  local path=$1
  if [ ! -w "$path" ]; then
    log "Error: Not writable path [$path]"
    return 1
  fi

  return 0
}

# Check if data exists in old structure and needs migration
detect_old_data_location() {
  if [ -f "$BASE_DIR/PG_VERSION" ]; then
    echo "$BASE_DIR"
    return 0
  fi
  return 1
}

# Migrate from old directory structure to new versioned structure
migrate_directory_structure() {
  local old_location="$1"
  local old_version
  old_version=$(cat "$old_location/PG_VERSION")

  local new_location="$BASE_DIR/$old_version/docker"

  dm_log "Detected data in old location: [$old_location]"
  dm_log "Migrating to new structure: [$new_location]"

  if [ -d "$new_location" ] && [ "$(ls -A "$new_location")" ]; then
    dm_log "ERROR: Target location [$new_location] already exists and is not empty."
    exit 1
  fi

  # Create parent directory
  mkdir -p "$new_location" || {
    dm_log "ERROR: Failed to create parent directory [$new_location]"
    exit 1
  }

  # Ensure both locations are on the same filesystem
  check_same_filesystem "$old_location" "$new_location" || exit 1

  # Use rsync to copy everything, preserving permissions
  dm_log "Moving data from [$old_location] to [$new_location] with rsync"
  # Use rsync to copy everything (including empty directories), except the newly created version directory
  # --archive preserves permissions, --remove-source-files deletes files after copy
  rsync --archive --remove-source-files --exclude="/$old_version" "$old_location/" "$new_location/" || exit 1

  dm_log "Cleaning up empty directories from [$old_location]"
  # Recursively delete empty directories, but exclude all versioned directories (numeric names)
  # This handles cases like base/, pg_wal/, etc. that are now empty after rsync
  find "$old_location" -mindepth 1 -type d -empty \
    ! -path "$old_location/[0-9]*" \
    ! -path "$old_location/[0-9]*/*" \
    -delete 2>/dev/null || true

  dm_log "Migration complete. Data now at: [$new_location]"
  return 0
}

# Perform the upgrade
perform_upgrade() {
  local old_data_dir="$1"
  local old_version="$2"
  local new_version="$3"

  up_log "Starting upgrade from PostgreSQL $old_version to $new_version"

  local old_bin_path
  old_bin_path=$(get_bin_path "$old_version")
  local new_bin_path
  new_bin_path=$(get_bin_path "$new_version")

  empty_line

  # Verify binaries exist
  if [ ! -f "$old_bin_path/pg_upgrade" ]; then
    up_log "ERROR: Old PostgreSQL [$old_version] binaries not found at [$old_bin_path]"
    exit 1
  fi

  if [ ! -f "$new_bin_path/pg_upgrade" ]; then
    up_log "ERROR: New PostgreSQL [$new_version] binaries not found at [$new_bin_path]"
    exit 1
  fi

  empty_line

  local new_data_dir="$BASE_DIR/$new_version/docker"

  if [ -d "$new_data_dir" ]; then
    up_log "ERROR: Directory [$new_data_dir] already exists."
    exit 1
  fi

  # Initialize new data directory
  up_log "Initializing new data directory: $new_data_dir"
  mkdir -p "$new_data_dir" || {
    up_log "ERROR: Failed to create new data directory [$new_data_dir]"
    exit 1
  }

  export PGUSER="$POSTGRES_USER"
  export PGDATA="$new_data_dir"

  # Check if old cluster has checksums enabled
  local old_checksums_enabled=false
  if "$old_bin_path"/pg_checksums --check --pgdata="$old_data_dir" >/dev/null 2>&1; then
    old_checksums_enabled=true
    up_log "Old cluster has checksums enabled"
  else
    up_log "Old cluster has checksums disabled"
  fi

  # Add checksum flag to POSTGRES_INITDB_ARGS
  local original_initdb_args="${POSTGRES_INITDB_ARGS:-}"
  if [ "$old_checksums_enabled" = true ]; then
    export POSTGRES_INITDB_ARGS="${original_initdb_args} --data-checksums"
  else
    export POSTGRES_INITDB_ARGS="${original_initdb_args} --no-data-checksums"
  fi

  up_log "Using docker_init_database_dir from upstream entrypoint"
  empty_line
  docker_init_database_dir
  empty_line

  # Restore original POSTGRES_INITDB_ARGS
  export POSTGRES_INITDB_ARGS="$original_initdb_args"

  # Create backup before upgrade
  local timestamp
  timestamp=$(date +%Y%m%d%H%M%S)
  local backup_dir="$BASE_DIR/backups"
  mkdir -p "$backup_dir"

  local backup_file="$backup_dir/pre-upgrade-${old_version}-to-${new_version}-${timestamp}.tar.gz"
  up_log "Creating backup: $backup_file"
  tar -czf "$backup_file" -C "$(dirname "$old_data_dir")" "$(basename "$old_data_dir")"

  # Compatibility check
  up_log "Running compatibility check..."
  if ! "$new_bin_path"/pg_upgrade \
    --old-bindir="$old_bin_path" \
    --new-bindir="$new_bin_path" \
    --old-datadir="$old_data_dir" \
    --new-datadir="$new_data_dir" \
    --socketdir=/var/run/postgresql \
    --link \
    --check; then
    up_log "ERROR: Compatibility check failed"
    exit 1
  fi

  up_log "Compatibility check passed"

  # Perform actual upgrade
  up_log "Performing upgrade..."
  if ! "$new_bin_path"/pg_upgrade \
    --old-bindir="$old_bin_path" \
    --new-bindir="$new_bin_path" \
    --old-datadir="$old_data_dir" \
    --new-datadir="$new_data_dir" \
    --socketdir=/var/run/postgresql \
    --link; then
    up_log "ERROR: Upgrade failed"
    exit 1
  fi

  up_log "Upgrade completed successfully"

  # Copy important config files
  up_log "Copying configuration files..."
  for conf_file in pg_hba.conf postgresql.conf pg_ident.conf; do
    if [ -f "$old_data_dir/$conf_file" ]; then
      cp "$old_data_dir/$conf_file" "$new_data_dir/$conf_file"
      up_log "Copied $conf_file"
    fi
  done

  up_log "Upgrade process complete"
  up_log "Old data preserved at: $old_data_dir"
  up_log "New data location: $new_data_dir"
  up_log "Backup available at: $backup_file"
}

log "Starting entrypoint with migration and upgrade handling"

if [ -z "$TARGET_VERSION" ]; then
  log "ERROR: TARGET_VERSION is not set"
  exit 1
fi

correct_pg_data="$BASE_DIR/$TARGET_VERSION/docker"
if [ "$PGDATA" != "$correct_pg_data" ]; then
  log "ERROR: PGDATA is not set to the correct location [$PGDATA != $correct_pg_data]"
  exit 1
fi

check_writable "$BASE_DIR" || exit 1
check_writable "/var/run/postgresql" || exit 1

# Check if we need to do directory migration first
if old_location=$(detect_old_data_location); then
  log "Old directory structure detected, performing migration"
  migrate_directory_structure "$old_location" || {
    log "ERROR: Migration failed"
    exit 1
  }
else
  log "No migration needed from old data location."
fi

# Now check for version-specific directories and find the HIGHEST version
found_version=""
found_data_dir=""
highest_version=0
for version_dir in "$BASE_DIR"/*/docker; do
  if [ -f "$version_dir/PG_VERSION" ]; then
    this_version=$(cat "$version_dir/PG_VERSION")
    log "Found database: PostgreSQL $this_version at $version_dir"

    # Track the highest version found
    if [ "$this_version" -gt "$highest_version" ]; then
      highest_version="$this_version"
      found_version="$this_version"
      found_data_dir="$version_dir"
    fi
  fi
done

# Check if we found any database
if [ -z "$found_version" ]; then
  log "No existing database found. Assuming this is a fresh install."
  exit 0
fi

log "Using highest version found: PostgreSQL [$found_version] at [$found_data_dir]"

# Use the found data directory
DATA_DIR="$found_data_dir"

OLD_VERSION=$(cat "$DATA_DIR/PG_VERSION")
log "Current version: $OLD_VERSION"
log "Target version: $TARGET_VERSION"

# Don't do anything if we're already at the target version.
if [ "$OLD_VERSION" -eq "$TARGET_VERSION" ]; then
  log "Already at target version $TARGET_VERSION"
  exit 0
fi

# Fail if we're downgrading.
if [ "$OLD_VERSION" -gt "$TARGET_VERSION" ]; then
  log "Cannot downgrade from $OLD_VERSION to $TARGET_VERSION"
  exit 1
fi

perform_upgrade "$DATA_DIR" "$OLD_VERSION" "$TARGET_VERSION"

log "Upgrade complete. New database available at: $BASE_DIR/$TARGET_VERSION/docker"
log "Done."

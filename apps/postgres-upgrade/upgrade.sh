#!/bin/bash
set -euo pipefail

get_bin_path() {
  local version=$1
  echo "/usr/lib/postgresql/$version/bin"
}

log() {
  echo "[ix-postgres-upgrade] - [$(date +'%Y-%m-%d %H:%M:%S')] - $1"
}

check_writable() {
  local path=$1
  if [ ! -w "$path" ]; then
    log "$path is not writable"
    return 1
  fi

  return 0
}

check_writable "$DATA_DIR" || { echo "Data directory [$DATA_DIR] is not writable"; exit 1; }

# Don't do anything if its a fresh install.
if [ ! -f "$DATA_DIR/PG_VERSION" ]; then
  log "File $DATA_DIR/PG_VERSION does not exist. Assuming this is a fresh install."
  exit 0
fi

# Don't do anything if we're already at the target version.
OLD_VERSION=$(cat "$DATA_DIR/PG_VERSION")
log "Current version: $OLD_VERSION"
log "Target version: $TARGET_VERSION"
if [ "$OLD_VERSION" -eq "$TARGET_VERSION" ]; then
  log "Already at target version $TARGET_VERSION"
  exit 0
fi

# Fail if we're downgrading.
if [ "$OLD_VERSION" -gt "$TARGET_VERSION" ]; then
  log "Cannot downgrade from $OLD_VERSION to $TARGET_VERSION"
  exit 1
fi

export OLD_PG_BINARY=$(get_bin_path "$OLD_VERSION")
if [ ! -f "$OLD_PG_BINARY/pg_upgrade" ]; then
  log "File $OLD_PG_BINARY/pg_upgrade does not exist."
  exit 1
fi

export NEW_PG_BINARY=$(get_bin_path "$TARGET_VERSION")
if [ ! -f "$NEW_PG_BINARY/pg_upgrade" ]; then
  log "File $NEW_PG_BINARY/pg_upgrade does not exist."
  exit 1
fi

export NEW_DATA_DIR="/tmp/new-data-dir"
if [ -d "$NEW_DATA_DIR" ]; then
  log "Directory $NEW_DATA_DIR already exists."
  exit 1
fi

export PGUSER="$POSTGRES_USER"
export POSTGRES_INITDB_ARGS="${POSTGRES_INITDB_ARGS:-}"
log "Creating new data dir and initializing..."
PGDATA="$NEW_DATA_DIR" eval "initdb --username=$POSTGRES_USER --pwfile=<(echo $POSTGRES_PASSWORD) $POSTGRES_INITDB_ARGS"

timestamp=$(date +%Y%m%d%H%M%S)
backup_name="backup-$timestamp-$OLD_VERSION-$TARGET_VERSION.tar.gz"
log "Backing up $DATA_DIR to $NEW_DATA_DIR/$backup_name"
tar -czf "$NEW_DATA_DIR/$backup_name" "$DATA_DIR"

log "Using old pg_upgrade [$OLD_PG_BINARY/pg_upgrade]"
log "Using new pg_upgrade [$NEW_PG_BINARY/pg_upgrade]"
log "Checking upgrade compatibility of $OLD_VERSION to $TARGET_VERSION..."

"$NEW_PG_BINARY"/pg_upgrade \
  --old-bindir="$OLD_PG_BINARY" \
  --new-bindir="$NEW_PG_BINARY" \
  --old-datadir="$DATA_DIR" \
  --new-datadir="$NEW_DATA_DIR" \
  --socketdir /var/run/postgresql \
  --check

log "Compatibility check passed."

log "Upgrading from $OLD_VERSION to $TARGET_VERSION..."
"$NEW_PG_BINARY"/pg_upgrade \
  --old-bindir="$OLD_PG_BINARY" \
  --new-bindir="$NEW_PG_BINARY" \
  --old-datadir="$DATA_DIR" \
  --new-datadir="$NEW_DATA_DIR" \
  --socketdir /var/run/postgresql

log "Upgrade complete."

log "Copying old pg_hba.conf to new pg_hba.conf"
# We need to carry this over otherwise
cp "$DATA_DIR/pg_hba.conf" "$NEW_DATA_DIR/pg_hba.conf"

log "Replacing contents of $DATA_DIR with contents of $NEW_DATA_DIR (including the backup)."
rsync --archive --delete "$NEW_DATA_DIR/" "$DATA_DIR/"

log "Removing $NEW_DATA_DIR."
rm -rf "$NEW_DATA_DIR"

log "Done."

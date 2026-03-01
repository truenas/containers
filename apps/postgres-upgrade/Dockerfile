FROM postgres:18.2-trixie

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  rsync \
  zstd \
  wget \
  tzdata-legacy \
  ca-certificates \
  postgresql-15 \
  postgresql-16 \
  postgresql-17 \
  postgresql-17-postgis-3 \
  postgresql-18-postgis-3 \
  postgresql-17-pgvector \
  postgresql-18-pgvector \
  postgresql-17-cron \
  postgresql-18-cron \
  postgresql-17-pg-ivm \
  postgresql-18-pg-ivm

WORKDIR /tmp

# renovate: datasource=github-releases depName=tensorchord/VectorChord
ENV VCHORD_VERSION=0.5.3

# Install VectorChord from GitHub releases
RUN set -eux; \
  ARCH=$(dpkg --print-architecture) && \
  wget -q "https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-15-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  wget -q "https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-17-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  wget -q "https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-18-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  apt-get install -y --no-install-recommends \
  "./postgresql-15-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" \
  "./postgresql-17-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" \
  "./postgresql-18-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  rm -f ./*.deb

# renovate: datasource=github-releases depName=paradedb/paradedb
ENV PARADEDB_VERSION=0.21.10

# Install ParadeDB pg_search extension from GitHub releases
RUN set -eux; \
  ARCH=$(dpkg --print-architecture) && \
  wget -q "https://github.com/paradedb/paradedb/releases/download/v${PARADEDB_VERSION}/postgresql-18-pg-search_${PARADEDB_VERSION}-1PARADEDB-trixie_${ARCH}.deb" && \
  apt-get install -y --no-install-recommends \
  "./postgresql-18-pg-search_${PARADEDB_VERSION}-1PARADEDB-trixie_${ARCH}.deb" && \
  rm -f ./*.deb

# Ensure listen_addresses is set to '*' for all PostgreSQL versions
# This matches the default behavior of the official PostgreSQL Docker images
# https://github.com/docker-library/postgres/blob/9c515320bc6aa1243585763eb1696118969ffef0/14/bookworm/Dockerfile#L179-L180
RUN set -eux; \
  sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/15/postgresql.conf.sample && \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/15/postgresql.conf.sample
RUN set -eux; \
  sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/16/postgresql.conf.sample && \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/16/postgresql.conf.sample
RUN set -eux; \
  sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/17/postgresql.conf.sample && \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/17/postgresql.conf.sample

RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /var/lib/postgresql

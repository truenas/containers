FROM postgres:19.0-trixie@sha256:bb6e70add742cd868fb62cb3b2f67d1dd2bdd2b65a521e778420748753687c60

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  rsync \
  wget \
  tzdata-legacy \
  ca-certificates \
  postgresql-16 \
  postgresql-17 \
  postgresql-18 \
  postgresql-17-postgis-3 \
  postgresql-18-postgis-3 \
  postgresql-19-postgis-3 \
  postgresql-17-pgvector \
  postgresql-18-pgvector \
  postgresql-19-pgvector \
  postgresql-17-cron \
  postgresql-18-cron \
  postgresql-19-cron \
  postgresql-17-pg-ivm \
  postgresql-18-pg-ivm \
  postgresql-19-pg-ivm

# pgcron is used by paradedb, and ossapps (splitpro)
# pgivm is used by paradedb

WORKDIR /tmp

# renovate: datasource=github-releases depName=supervc-stack/VectorChord
ENV VCHORD_VERSION=1.1.1

# Install VectorChord from GitHub releases
# TODO: Add PostgreSQL 19 once VectorChord publishes postgresql-19-vchord
RUN set -eux; \
  ARCH=$(dpkg --print-architecture) && \
  wget -q "https://github.com/supervc-stack/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-17-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  wget -q "https://github.com/supervc-stack/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-18-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  apt-get install -y --no-install-recommends \
  "./postgresql-17-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" \
  "./postgresql-18-vchord_${VCHORD_VERSION}-1_${ARCH}.deb" && \
  rm -f ./*.deb

# renovate: datasource=github-releases depName=paradedb/paradedb
ENV PARADEDB_VERSION=0.27.0

# Install ParadeDB pg_search extension from GitHub releases
# TODO: Add PostgreSQL 19 once ParadeDB publishes postgresql-19-pg-search
RUN set -eux; \
  ARCH=$(dpkg --print-architecture) && \
  wget -q "https://github.com/paradedb/paradedb/releases/download/v${PARADEDB_VERSION}/postgresql-18-pg-search_${PARADEDB_VERSION}-1PARADEDB-trixie_${ARCH}.deb" && \
  apt-get install -y --no-install-recommends \
  "./postgresql-18-pg-search_${PARADEDB_VERSION}-1PARADEDB-trixie_${ARCH}.deb" && \
  rm -f ./*.deb

# Ensure listen_addresses is set to '*' for all PostgreSQL versions
# This matches the default behavior of the official PostgreSQL Docker images
# https://github.com/docker-library/postgres/blob/9c515320bc6aa1243585763eb1696118969ffef0/14/bookworm/Dockerfile#L179-L180
# The base image already does this for its own version, the versions installed above need it too.
# v16 is used by Asigra Enterprise app.
RUN set -eux; \
  for version in 16 17 18; do \
    sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" "/usr/share/postgresql/$version/postgresql.conf.sample"; \
    grep -F "listen_addresses = '*'" "/usr/share/postgresql/$version/postgresql.conf.sample"; \
  done

RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /var/lib/postgresql

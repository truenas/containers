FROM postgres:18.1-trixie

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  rsync \
  zstd \
  tzdata-legacy \
  postgresql-15 \
  postgresql-16 \
  postgresql-17

# Ensure listen_addresses is set to '*' for all PostgreSQL versions
# This matches the default behavior of the official PostgreSQL Docker images
# https://github.com/docker-library/postgres/blob/9c515320bc6aa1243585763eb1696118969ffef0/14/bookworm/Dockerfile#L179-L180
RUN \
  sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/15/postgresql.conf.sample && \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/15/postgresql.conf.sample
RUN \
  sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/16/postgresql.conf.sample && \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/16/postgresql.conf.sample
RUN \ sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/17/postgresql.conf.sample && \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/17/postgresql.conf.sample

RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /var/lib/postgresql

FROM postgres:18.1-trixie

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  rsync \
  zstd \
  tzdata-legacy \
  postgresql-15 \
  postgresql-16 \
  postgresql-17 \
  postgresql-17-postgis-3 \
  postgresql-18-postgis-3

RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /var/lib/postgresql

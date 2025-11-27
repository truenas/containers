FROM postgres:18.1-bookworm

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  rsync \
  postgresql-15 \
  postgresql-16 \
  postgresql-17

RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /var/lib/postgresql

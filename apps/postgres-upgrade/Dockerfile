FROM postgres:18.1-bookworm

RUN apt update

RUN apt install -y --no-install-recommends \
  rsync \
  postgresql-15 \
  postgresql-16 \
  postgresql-17

RUN apt autoremove -y
RUN apt autoclean -y
RUN rm -rf /var/lib/apt/lists/*

COPY upgrade.sh /upgrade.sh
RUN chmod 777 /upgrade.sh

WORKDIR /tmp

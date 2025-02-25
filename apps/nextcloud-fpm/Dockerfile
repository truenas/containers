FROM nextcloud:30.0.6-fpm

RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  jq \
  nano \
  libfcgi-bin \
  ;

# See https://github.com/nextcloud/docker/issues/763
RUN set -ex; \
  \
  touch /usr/local/etc/php/conf.d/redis-session.ini; \
  chmod 777 /usr/local/etc/php/conf.d/redis-session.ini

COPY --chmod=755 ./scripts/occ /usr/bin/occ
COPY --chmod=755 ./scripts/healthcheck.sh /healthcheck.sh

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

# Copy the healthcheck
COPY --chmod=755 ./scripts/healthcheck.sh /healthcheck.sh

# Copy the occ shortcut
COPY --chmod=755 ./scripts/occ /usr/bin/occ

# Copy the configure-scripts that will be sourced by the post-install
COPY --chmod=755 ./configure-scripts /configure-scripts

# Copy post-install script to the `before-starting` hooks dir so nextcloud will run those automatically.
COPY --chmod=755 ./scripts/post-install.sh /docker-entrypoint-hooks.d/before-starting/10-post-install.sh

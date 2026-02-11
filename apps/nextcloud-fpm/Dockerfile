FROM nextcloud:32.0.5-fpm

# Adds SURY PHP repository (This is a workaround because IMAP php extension is no longer available in Debian Trixie)
# https://github.com/nextcloud/docker/issues/2456
# https://www.voodoo.business/blog/2025/08/11/trixie-php8-4-imap-missing/
# https://wiki.debian.org/AdditionalPHPVersions (Quotes "The SURY repository is a reputable repository by web hosting professionals worldwide, but IT'S NOT A OFFICIAL DEBIAN REPOSITORY. You have been warned.")
RUN set -ex \
  && apt-get update \
  && apt-get install -y --no-install-recommends gnupg2 lsb-release \
  && echo "deb https://packages.sury.org/php $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list \
  && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-php.gpg \
  \
  && apt-get update \
  # Development files for c-client mail API (used by IMAP)
  && apt-get install -y --no-install-recommends libc-client-dev \
  && apt-get dist-clean \
  \
  # Block the repository completely for future use
  && echo "Package: *" > /etc/apt/preferences.d/99-pin-sury \
  && echo "Pin: origin packages.sury.org" >> /etc/apt/preferences.d/99-pin-sury \
  && echo "Pin-Priority: -1" >> /etc/apt/preferences.d/99-pin-sury

RUN set -ex \
  \
  && apt-get update \
  # Install necessary runtime packages without recommended packages
  && apt-get install -y --no-install-recommends \
  # Tool for parsing and manipulating JSON
  jq \
  # Simple text editor for the terminal
  nano \
  # Utilities for monitoring processes
  procps \
  # Multimedia framework for handling audio/video
  ffmpeg \
  # Library for HEIF image format support
  libheif1 \
  # Tool for adding OCR text layer to scanned PDF files, making them searchable
  ocrmypdf \
  # Client for accessing Windows/Samba file shares
  smbclient \
  # Library for H.265/HEVC video format
  libde265-0 \
  # Office suite (document, spreadsheet, presentation apps)
  libreoffice \
  # FastCGI utilities for web servers
  libfcgi-bin \
  # Plugin to display HEIF images in GTK applications
  heif-gdk-pixbuf \
  # Common files for ImageMagick (image manipulation tool)
  imagemagick-common \
  \
  # Save a list of currently manually installed packages
  # This will be used later to restore the package state after building
  && savedAptMark="$(apt-mark showmanual)" \
  \
  # Install build dependencies needed for compiling PHP extensions
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  # Development files for bzip2 compression
  libbz2-dev \
  # Development files for Kerberos authentication
  libkrb5-dev \
  # Development files for the SMB client library
  libsmbclient-dev \
  # Development files for ImageMagick core functionality
  libmagickcore-dev \
  \
  # Configure the PHP IMAP extension with additional features
  # --with-kerberos: Add Kerberos authentication support
  # --with-imap-ssl: Add SSL encryption support
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  # Install PHP extensions using the Docker PHP extension installer
  && docker-php-ext-install \
  # Adds support for bzip2 compression in PHP
  bz2 \
  # Adds support for IMAP mail protocol in PHP
  imap \
  # Adds support for SOAP web services in PHP
  soap \
  # Install the smbclient extension from PECL (PHP Extension Community Library)
  # This allows PHP to interact with Windows/Samba file shares
  && pecl install smbclient \
  # Enable the smbclient extension in PHP
  && docker-php-ext-enable smbclient \
  \
  # Mark all packages as automatically installed
  # This prepares for clean-up of packages that were only needed for building
  && apt-mark auto '.*' > /dev/null \
  # Restore the packages that were manually installed before we started
  && apt-mark manual $savedAptMark \
  \
  # Find and mark as manually installed any shared libraries that
  # our PHP extensions depend on, so they don't get removed in the cleanup
  && ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
  | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
  | sort -u \
  | xargs -rt dpkg-query --search \
  | cut -d: -f1 \
  | sort -u \
  | xargs -rt apt-mark manual \
  \
  # Remove packages that were only needed for building extensions
  # -o APT::AutoRemove::RecommendsImportant=false: Also remove recommended packages that are no longer needed
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  # Clean up the package cache to reduce the size of the Docker image
  && apt-get dist-clean

# renovate: datasource=github-releases depName=aptible/supercronic
ENV SUPERCRONIC_VERSION=v0.2.43
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64
RUN curl -fsSL ${SUPERCRONIC_URL} -o /usr/local/bin/supercronic && \
  chmod +x /usr/local/bin/supercronic

# renovate: datasource=github-releases depName=mikefarah/yq
ENV YQ_VERSION=v4.50.1
ENV YQ_URL="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"
RUN \
  curl -fsSL "${YQ_URL}" -o /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq

# See https://github.com/nextcloud/docker/issues/763
RUN set -ex \
  \
  && touch /usr/local/etc/php/conf.d/redis-session.ini \
  && chmod 777 /usr/local/etc/php/conf.d/redis-session.ini

# Copy the healthcheck
COPY --chmod=755 ./scripts/healthcheck.sh /healthcheck.sh
# Copy the occ shortcut
COPY --chmod=755 ./scripts/occ /usr/bin/occ
# Copy the configure-scripts that will be sourced by the post-install
COPY --chmod=755 ./configure-scripts /configure-scripts
# Copy post-install script to the `before-starting` hooks dir so nextcloud will run those automatically.
COPY --chmod=755 ./scripts/post-install.sh /docker-entrypoint-hooks.d/before-starting/10-post-install.sh
# Copy the php-cron script (wraps nextcloud cron.php)
COPY --chmod=755 ./scripts/php-cron /php-cron
# Copy the supercronic cron daemon script
COPY --chmod=755 ./scripts/cron.sh /cron.sh

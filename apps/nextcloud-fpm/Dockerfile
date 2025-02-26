FROM nextcloud:31.0.0-fpm

RUN set -ex; \
  \
  apt-get update; \
  # Install necessary runtime packages without recommended packages
  apt-get install -y --no-install-recommends \
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
  ; \
  \
  # Save a list of currently manually installed packages
  # This will be used later to restore the package state after building
  savedAptMark="$(apt-mark showmanual)"; \
  \
  # Install build dependencies needed for compiling PHP extensions
  apt-get update; \
  apt-get install -y --no-install-recommends \
  # Development files for bzip2 compression
  libbz2-dev \
  # Development files for Kerberos authentication
  libkrb5-dev \
  # Development files for c-client mail API (used by IMAP)
  libc-client-dev \
  # Development files for the SMB client library
  libsmbclient-dev \
  # Development files for ImageMagick core functionality
  libmagickcore-dev \
  ; \
  \
  # Configure the PHP IMAP extension with additional features
  # --with-kerberos: Add Kerberos authentication support
  # --with-imap-ssl: Add SSL encryption support
  docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
  # Install PHP extensions using the Docker PHP extension installer
  docker-php-ext-install \
  # Adds support for bzip2 compression in PHP
  bz2 \
  # Adds support for IMAP mail protocol in PHP
  imap \
  ; \
  # Install the smbclient extension from PECL (PHP Extension Community Library)
  # This allows PHP to interact with Windows/Samba file shares
  pecl install smbclient; \
  # Enable the smbclient extension in PHP
  docker-php-ext-enable smbclient; \
  \
  # Mark all packages as automatically installed
  # This prepares for clean-up of packages that were only needed for building
  apt-mark auto '.*' > /dev/null; \
  # Restore the packages that were manually installed before we started
  apt-mark manual $savedAptMark; \
  \
  # Find and mark as manually installed any shared libraries that
  # our PHP extensions depend on, so they don't get removed in the cleanup
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
  | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
  | sort -u \
  | xargs -r dpkg-query --search \
  | cut -d: -f1 \
  | sort -u \
  | xargs -rt apt-mark manual; \
  \
  # Remove packages that were only needed for building extensions
  # -o APT::AutoRemove::RecommendsImportant=false: Also remove recommended packages that are no longer needed
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  # Clean up the package cache to reduce the size of the Docker image
  rm -rf /var/lib/apt/lists/*

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

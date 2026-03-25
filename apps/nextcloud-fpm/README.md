# Nextcloud Configuration

## Environment Variables

### General

| Variable                      | Description                            |  App(s)  |     Config Key(s)      |  Default   |   Example   |
| ----------------------------- | -------------------------------------- | :------: | :--------------------: | :--------: | :---------: |
| `IX_RUN_OPTIMIZE`             | Runs optimize/repair/migration scripts |          |                        |   `true`   |   `false`   |
| `IX_MAINTENANCE_WINDOW_START` | Sets the maintenance window start      |          |                        |   `100`    |     `1`     |
| `IX_DEFAULT_PHONE_REGION`     | Default phone region                   | `system` | `default_phone_region` |    `GR`    |    `US`     |
| `IX_SHARED_FOLDER_NAME`       | Name of shared folder                  | `system` |  `share_folder_name`   |    `/`     |  `Shared`   |
| `IX_MAX_CHUNK_SIZE`           | Maximum chunk size                     | `files`  |    `max_chunk_size`    | `10485760` | `104857600` |

### Logging

| Variable             | Description     |  App(s)  |  Config Key(s)  |              Default               |        Example        |
| -------------------- | --------------- | :------: | :-------------: | :--------------------------------: | :-------------------: |
| `IX_LOG_LEVEL`       | Log level       | `system` |   `loglevel`    |                `2`                 |          `0`          |
| `IX_LOG_FILE`        | Log file        | `system` |    `logfile`    | `/var/www/html/data/nextcloud.log` | `/logs/nextcloud.log` |
| `IX_LOG_FILE_AUDIT`  | Audit log file  | `system` | `logfile_file`  |   `/var/www/html/data/audit.log`   |   `/logs/audit.log`   |
| `IX_LOG_DATE_FORMAT` | Log date format | `system` | `logdateformat` |           `d/m/Y H:i:s`            |    `D d/m/Y H:i:s`    |
| `IX_LOG_TIMEZONE`    | Log timezone    | `system` |  `logtimezone`  |               `$TZ`                |    `Europe/Athens`    |

### URLs

| Variable                | Description                             |  App(s)  |    Config Key(s)    | Default |                  Example                   |
| ----------------------- | --------------------------------------- | :------: | :-----------------: | :-----: | :----------------------------------------: |
| `IX_TRUSTED_DOMAINS`    | Space Separated list of Trusted domains | `system` |  `trusted_domains`  |  `""`   |       `localhost cloud.example.com`        |
| `IX_TRUSTED_PROXIES`    | Space Separated list of Trusted proxies | `system` |  `trusted_proxies`  |  `""`   | `10.0.0.0/8 172.16.0.0./12 192.168.0.0/16` |
| `IX_OVERWRITE_HOST`     | Overwrite host                          | `system` |   `overwritehost`   |  `""`   |            `cloud.example.com`             |
| `IX_OVERWRITE_CLI_URL`  | Overwrite CLI URL                       | `system` | `overwrite.cli.url` |  `""`   |        `https://cloud.example.com`         |
| `IX_OVERWRITE_PROTOCOL` | Overwrite protocol                      | `system` | `overwriteprotocol` |  `""`   |                  `https`                   |

### Notify Push

| Variable                  | Description                         |    App(s)     |      Config Key(s)       | Default |             Example              |
| ------------------------- | ----------------------------------- | :-----------: | :----------------------: | :-----: | :------------------------------: |
| `IX_NOTIFY_PUSH`          | Enable Nextcloud Push Notifications | `notify_push` | See `IX_NOTIFY_PUSH_URL` | `true`  |             `false`              |
| `IX_NOTIFY_PUSH_ENDPOINT` | Nextcloud Push Notifications URL    | `notify_push` |     `base_endpoint`      |  `""`   | `https://cloud.example.com/push` |

### Expiration/Retention

| Variable                  | Description                      |   App(s)   |          Config Key(s)          | Default | Example |
| ------------------------- | -------------------------------- | :--------: | :-----------------------------: | :-----: | :-----: |
| `IX_ACTIVITY_EXPIRE_DAYS` | Expire days for activity app     | `activity` |     `activity_expire_days`      |  `365`  |  `90`   |
| `IX_TRASH_RETENTION`      | Retention time for deleted files |  `system`  | `trashbin_retention_obligation` | `auto`  | `30,60` |
| `IX_VERSION_RETENTION`    | Retention time for old versions  |  `system`  | `versions_retention_obligation` | `auto`  | `30,60` |

### Redis

| Variable        | Description    |  App(s)  |  Config Key(s)   | Default |    Example    |
| --------------- | -------------- | :------: | :--------------: | :-----: | :-----------: |
| `IX_REDIS`      | Enable Redis   |          |                  | `true`  |    `false`    |
| `IX_REDIS_HOST` | Redis Host     | `system` |   `redis:host`   |  `""`   | `redis.local` |
| `IX_REDIS_PASS` | Redis Password | `system` | `redis:password` |  `""`   |  `my-secret`  |
| `IX_REDIS_PORT` | Redis Port     | `system` |   `redis:port`   | `6379`  |    `1234`     |

### Database

| Variable               | Description                |  App(s)  | Config Key(s) | Default |     Example     |
| ---------------------- | -------------------------- | :------: | :-----------: | :-----: | :-------------: |
| `IX_POSTGRES_HOST`     | Postgres Database Host     | `system` |   `dbhost`    |  `""`   | `192.168.1.100` |
| `IX_POSTGRES_NAME`     | Postgres Database Name     | `system` |   `dbname`    |  `""`   |   `nextcloud`   |
| `IX_POSTGRES_USER`     | Postgres Database User     | `system` |   `dbuser`    |  `""`   |   `nextcloud`   |
| `IX_POSTGRES_PASSWORD` | Postgres Database Password | `system` | `dbpassword`  |  `""`   |   `my-secret`   |
| `IX_POSTGRES_PORT`     | Postgres Database Port     | `system` |   `dbport`    | `5432`  |     `5555`      |

### Previews

| Variable                        | Description                                                                             |            App(s)             |                                           Config Key(s)                                            |  Default  |    Example     |
| ------------------------------- | --------------------------------------------------------------------------------------- | :---------------------------: | :------------------------------------------------------------------------------------------------: | :-------: | :------------: |
| `IX_PREVIEWS`                   | Enable Previews (Forced enabled if Imaginary is enabled)                                | `system` / `previewgenerator` | `system:enable_previews`, `system:enablePreviewProviders` and see `IX_PREVIEW_`, `IX_JPEG_QUALITY` |  `true`   |    `false`     |
| `IX_IMAGINARY`                  | Enable Imaginary                                                                        |           `system`            |                                      `preview_imaginary_url`                                       |  `true`   |    `false`     |
| `IX_PREVIEW_PROVIDERS`          | Space Separated list of Preview providers (Imaginary is added automatically if enabled) |           `system`            |                                     `enabledPreviewProviders`                                      |   `""`    | `JPEG PNG BPM` |
| `IX_PREVIEW_MAX_X`              | Maximum width of preview image                                                          |           `system`            |                                          `preview_max_x`                                           |  `2048`   |     `1024`     |
| `IX_PREVIEW_MAX_Y`              | Maximum height of preview image                                                         |           `system`            |                                          `preview_max_y`                                           |  `2048`   |     `1024`     |
| `IX_PREVIEW_MAX_MEMORY`         | Maximum memory for preview image                                                        |           `system`            |                                        `preview_max_memory`                                        |  `1024`   |     `512`      |
| `IX_PREVIEW_MAX_FILESIZE_IMAGE` | Maximum file size for image previews                                                    |           `system`            |                                    `preview_max_filesize_image`                                    |   `50`    |      `25`      |
| `IX_JPEG_QUALITY`               | JPEG Quality for previews                                                               | `system` / `previewgenerator` |                           `system:jpeg_quality` / `preview:jpeg_quality`                           |   `60`    |      `80`      |
| `IX_PREVIEW_HEIGHT_SIZES`       | Preview height sizes                                                                    |      `previewgenerator`       |                                           `heightSizes`                                            |   `256`   |     `512`      |
| `IX_PREVIEW_WIDTH_SIZES`        | Preview width sizes                                                                     |      `previewgenerator`       |                                            `widthSizes`                                            | `256 384` |   `512 1024`   |
| `IX_PREVIEW_SQUARE_SIZES`       | Preview square sizes                                                                    |      `previewgenerator`       |                                           `squareSizes`                                            | `32 256`  |    `64 512`    |

### ClamAV

| Variable                      | Description              |      App(s)       |     Config Key(s)      |  Default   |    Example     |
| ----------------------------- | ------------------------ | :---------------: | :--------------------: | :--------: | :------------: |
| `IX_CLAMAV`                   | Enable ClamAV            |                   |                        |  `false`   |     `true`     |
| `IX_CLAMAV_HOST`              | ClamAV Host              | `files_antivirus` |       `av_host`        |    `""`    | `clamav.local` |
| `IX_CLAMAV_PORT`              | ClamAV Port              | `files_antivirus` |       `av_port`        |    `""`    |     `3310`     |
| `IX_CLAMAV_STREAM_MAX_LENGTH` | ClamAV Stream Max Length | `files_antivirus` | `av_stream_max_length` | `26214400` |   `1048576`    |
| `IX_CLAMAV_MAX_FILE_SIZE`     | ClamAV Max File Size     | `files_antivirus` |   `av_max_file_size`   |    `-1`    |   `1048576`    |
| `IX_CLAMAV_INFECTED_ACTION`   | ClamAV Infected Action   | `files_antivirus` |  `av_infected_action`  | `only_log` |    `delete`    |

### Collabora

| Variable                    | Description                                 |     App(s)      |   Config Key(s)   | Default |             Example             |
| --------------------------- | ------------------------------------------- | :-------------: | :---------------: | :-----: | :-----------------------------: |
| `IX_COLLABORA`              | Enable Collabora                            |                 |                   | `false` |             `true`              |
| `IX_COLLABORA_URL`          | Collabora URL                               | `richdocuments` | `public_wopi_url` |  `""`   | `https://collabora.example.com` |
| `IX_COLLABORA_INTERNAL_URL` | Collabora Internal URL                      | `richdocuments` |    `wopi_url`     |  `""`   |     `http://collabora:9980`     |
| `IX_COLLABORA_ALLOWLIST`    | Collabora WOPI Allow List (Comma Separated) | `richdocuments` | `wopi_allowlist`  |  `""`   |   `172.16.0.0/12,10.0.0.0/12`   |

### Onlyoffice

| Variable                   | Description           |    App(s)    |    Config Key(s)    | Default |             Example              |
| -------------------------- | --------------------- | :----------: | :-----------------: | :-----: | :------------------------------: |
| `IX_ONLYOFFICE`            | Enable OnlyOffice     |              |                     | `false` |              `true`              |
| `IX_ONLYOFFICE_URL`        | OnlyOffice URL        | `onlyoffice` | `DocumentServerUrl` |  `""`   | `https://onlyoffice.example.com` |
| `IX_ONLYOFFICE_JWT`        | OnlyOffice JWT        | `onlyoffice` |    `jwt_secret`     |  `""`   |  `random_string_of_characters`   |
| `IX_ONLYOFFICE_JWT_HEADER` | OnlyOffice JWT Header | `onlyoffice` |    `jwt_header`     |  `""`   |         `Authorization`          |

### Talk

| Variable                          | Description                  |  App(s)  |    Config Key(s)    | Default |       Example        |
| --------------------------------- | ---------------------------- | :------: | :-----------------: | :-----: | :------------------: |
| `IX_TALK`                         | Enable Talk                  |          |                     | `false` |        `true`        |
| `IX_TALK_STUN_SERVER`             | Talk STUN server             | `spreed` |   `stun_servers`    |  `""`   |     `stun1:3478`     |
| `IX_TALK_TURN_SERVER`             | Talk TURN server             | `spreed` |   `turn_servers`    |  `""`   |     `turn1:1234`     |
| `IX_TALK_TURN_SECRET`             | Talk TURN secret             | `spreed` |   `turn_servers`    |  `""`   |    `some_secret`     |
| `IX_TALK_SIGNALING_SERVER`        | Talk Signaling server        | `spreed` | `signaling_servers` |  `""`   | `signal.example.com` |
| `IX_TALK_SIGNALING_SERVER_VERIFY` | Talk Signaling server verify | `spreed` | `signaling_servers` | `true`  |       `false`        |
| `IX_TALK_SIGNALING_SECRET`        | Talk Signaling secret        | `spreed` | `signaling_secret`  |  `""`   |    `some_secret`     |

> Visit Nextcloud official documentation for more information about each `Config key`
>
> Also see [config example](https://github.com/nextcloud/server/blob/master/config/config.sample.php)

## Recommended additions for nextcloud optimizations

> Partial docker-compose file

```yaml
services:
  nextcloud:
    configs:
      - source: php-tune
        target: /usr/local/etc/php-fpm.d/zz-tune.conf
      - source: redis-session
        target: /usr/local/etc/php/conf.d/redis-session.ini
      - source: opcache-recommended
        target: /usr/local/etc/php/conf.d/opcache-recommended.ini

configs:
  php-tune:
    content: |
      [www]
      pm.max_children = 180
      pm.start_servers = 18
      pm.min_spare_servers = 12
      pm.max_spare_servers = 30
  redis-session:
    content: |
      session.save_handler = redis
      session.save_path = "tcp://redis:6379?auth=REPLACE_ME"
      redis.session.locking_enabled = 1
      redis.session.lock_retries = -1
      redis.session.lock_wait_time = 10000
  opcache-recommended:
    content: |
      opcache.enable=1
      opcache.enable_cli=1
      opcache.save_comments=1
      opcache.jit=1255
      opcache.interned_strings_buffer=32
      opcache.max_accelerated_files=10000
      opcache.memory_consumption=128
      opcache.revalidate_freq=60
      opcache.jit_buffer_size=128M
```

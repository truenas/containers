FROM alpine:3.23.3

RUN apk add --no-cache \
  curl \
  tzdata

# renovate: datasource=github-releases depName=aptible/supercronic
ENV SUPERCRONIC_VERSION=v0.2.42
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64
RUN curl -fsSL ${SUPERCRONIC_URL} -o /usr/local/bin/supercronic && \
  chmod +x /usr/local/bin/supercronic

ENV CRON_TAB_FILE=/crontab
COPY cron.sh /cron.sh
RUN chmod +x /cron.sh

USER 568

RUN /usr/local/bin/supercronic --version

ENTRYPOINT ["/cron.sh"]

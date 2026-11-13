FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

RUN apk add --no-cache \
  curl \
  tzdata

# renovate: datasource=github-releases depName=aptible/supercronic
ENV SUPERCRONIC_VERSION=v0.2.51
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64
RUN curl -fsSL ${SUPERCRONIC_URL} -o /usr/local/bin/supercronic && \
  chmod +x /usr/local/bin/supercronic

ENV CRON_TAB_FILE=/crontasks
COPY cron.sh /cron.sh
RUN chmod +x /cron.sh

USER 568

RUN /usr/local/bin/supercronic --version
ENV METRICS_PORT=8080

HEALTHCHECK CMD curl -fsSo /dev/null http://127.0.0.1:8080/health

ENTRYPOINT ["/cron.sh"]

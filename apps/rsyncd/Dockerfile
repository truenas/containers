FROM alpine:latest

LABEL maintainer="iXsystems <dev@ixsystems.com>"
LABEL description="rsynd on alpine linux"

RUN apk add --no-cache rsync

ENTRYPOINT ["rsync", "--daemon", "--no-detach", "--config=/etc/rsyncd.conf"]

HEALTHCHECK --interval=5s --timeout=10s --retries=3 \
    CMD getent services rsync || exit 1

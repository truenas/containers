FROM debian:bookworm-slim

LABEL maintainer="iXsystems <dev@ixsystems.com>"
LABEL description="rsynd on debian bookworm"

RUN apt update && \
    apt install -y rsync procps && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN rsync --version

ENTRYPOINT ["rsync", "--daemon", "--no-detach", "--config=/etc/rsyncd.conf"]

HEALTHCHECK --interval=5s --timeout=10s --retries=3 \
    CMD pgrep rsync || exit 1

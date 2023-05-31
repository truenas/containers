FROM debian:bookworm-slim

LABEL maintainer="iXsystems <dev@ixsystems.com>"
LABEL description="rsynd on debian bookworm"

RUN apt update && \
    apt install -y rsync && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["rsync", "--daemon", "--no-detach", "--config=/etc/rsyncd.conf"]

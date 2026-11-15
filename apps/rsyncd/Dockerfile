FROM debian:13.7-slim@sha256:a72b4433de1cf7d6bae0c4cee74d0547f58601a643b3375f070c51600d63b6b2

LABEL maintainer="TrueNAS Engineering <dev@truenas.com>"
LABEL description="rsynd on debian trixie"

RUN apt update && \
    apt install -y rsync=3.5.0+ds1-0+deb13u1 procps && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN rsync --version

ENTRYPOINT ["rsync", "--daemon", "--no-detach", "--config=/etc/rsyncd.conf"]

HEALTHCHECK --interval=5s --timeout=10s --retries=3 \
    CMD pgrep rsync || exit 1

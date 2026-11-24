FROM debian:13.8-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0

LABEL maintainer="TrueNAS Engineering <dev@truenas.com>"
LABEL description="rsynd on debian trixie"

RUN apt update && \
    apt install -y rsync=3.5.0+ds1-0+deb13u2 procps && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN rsync --version

ENTRYPOINT ["rsync", "--daemon", "--no-detach", "--config=/etc/rsyncd.conf"]

HEALTHCHECK --interval=5s --timeout=10s --retries=3 \
    CMD pgrep rsync || exit 1

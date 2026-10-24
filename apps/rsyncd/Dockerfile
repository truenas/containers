FROM debian:13.7-slim@sha256:62bd423aeee912639ca8ee681c2b762cb3e25137e0a92b20be455898a9f034ad

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

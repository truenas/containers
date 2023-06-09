FROM alpine:latest
LABEL maintainer="iXsystems <dev@ixsystems.com>"
LABEL description="tftpd-hpa server on alpine linux"

# set UID/GID for tftp
ENV UID=9069 \
    GID=9069

VOLUME /tftpboot
EXPOSE 69/udp

# add user tftp
RUN addgroup -g $GID -S tftp && \
    adduser --disabled-password \
            --gecos "" \
            --shell /sbin/nologin \
            --home /home/tftp \
            --no-create-home \
            --ingroup tftp \
            --uid $UID tftp

# add tftp-hpa
RUN apk add --no-cache \
            tftp-hpa \
            runit \
            tzdata && \
    mkdir -p /tftpboot \
        /runit-services \
        /runit-services/tftpd-hpa \
        /runit-services/syslogd && \
    echo -e "#!/bin/sh\nbusybox syslogd -n -O /dev/stdout" > \
        /runit-services/syslogd/run && \
    echo -e "#!/bin/sh\n/usr/sbin/in.tftpd --foreground --address 0.0.0.0:69 \
        --user tftp --verbose --secure /tftpboot" > \
        /runit-services/tftpd-hpa/run && \
    chmod +x /runit-services/syslogd/run \
        /runit-services/tftpd-hpa/run

# tftpd-hpa environment variables
# (see: https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html)
ENV TZ="UTC" \
    CREATE=0 \
    MAPFILE="" \
    PERMISSIVE=0 \
    PORTRANGE="4096:32760" \
    REFUSE="" \
    RETRANSMIT="" \
    SECURE=1 \
    TIMEOUT="" \
    UMASK="" \
    VERBOSE=1 \
    VERBOSITY=3

# add mapfile
# Currently its all empty
COPY mapfile $MAPFILE

# add docker-entrypoint.sh
COPY ./docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]

ENTRYPOINT ["/docker-entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=10s --retries=3 \
    CMD getent services tftp || exit 1

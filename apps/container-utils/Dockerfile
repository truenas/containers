FROM mikefarah/yq:4.54.1@sha256:4b3d9475d65571d28cbb19544d3820ec2945e4c8b2f18279394282b8dc3a592e AS yq

FROM python:3.15-slim-trixie@sha256:533b0b2f9b5d46fd097091cf826f27902f1d6c3bca714b6dc74551356aa97a51

USER root

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  jq \
  openssl \
  unzip \
  xz-utils && \
  rm -rf /var/lib/apt/lists/*

COPY --from=yq /usr/bin/yq /usr/local/bin/yq

COPY ./permissions.py /script/permissions.py
RUN chmod +x /script/permissions.py

# Must work under any uid (with no passwd entry), read-only rootfs and no caps.
# Only permissions.py needs root, and the library sets that explicitly.
ENV HOME=/tmp \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

USER 568:568

WORKDIR /tmp

RUN yq --version && \
  jq --version && \
  curl --version && \
  openssl version && \
  unzip -v && \
  xz --version

FROM mikefarah/yq:4.54.3@sha256:7834187596ad56fd5a81436114e0b0b9dd54c91bb43946d1f7145b2be5f9c3d2 AS yq

FROM python:3.15-slim-trixie@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928

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

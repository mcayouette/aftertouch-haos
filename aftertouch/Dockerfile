# ── AfterTouch soundtouch-service — Dockerfile ────────────────────────────────
#
# This Dockerfile is used when building the add-on LOCALLY (e.g. with
# `ha addon build` or the Home Assistant builder action). When installed from
# a repository, Home Assistant Supervisor pulls the pre-built image specified
# by the `image:` key in config.yaml (ghcr.io/gesellix/bose-soundtouch) and
# this Dockerfile is NOT executed.
#
# To force a local build, remove or comment out the `image:` line in
# config.yaml.
# ──────────────────────────────────────────────────────────────────────────────

ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

# Labels required by Home Assistant Supervisor
LABEL \
  io.hass.version="0.118.0" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

# Install bash, ca-certificates, wget, and tzdata
RUN apk add --no-cache \
    bash \
    ca-certificates \
    wget \
    tzdata

# Download the soundtouch-service binary for the target architecture.
# Upstream release: https://github.com/gesellix/Bose-SoundTouch/releases/tag/v0.118.0
ARG BUILD_ARCH
ARG BUILD_VERSION=0.118.0

RUN set -ex; \
    case "${BUILD_ARCH}" in \
      aarch64) GOARCH="arm64" ;; \
      amd64)   GOARCH="amd64" ;; \
      *)       echo "Unsupported arch: ${BUILD_ARCH}" && exit 1 ;; \
    esac; \
    BASE_URL="https://github.com/gesellix/Bose-SoundTouch/releases/download/v${BUILD_VERSION}"; \
    # Try common naming conventions used by Go release tools (goreleaser)
    wget -q -O /usr/local/bin/soundtouch-service \
        "${BASE_URL}/soundtouch-service_linux_${GOARCH}" \
    || wget -q -O /usr/local/bin/soundtouch-service \
        "${BASE_URL}/soundtouch-service-linux-${GOARCH}" \
    || wget -q -O /usr/local/bin/soundtouch-service \
        "${BASE_URL}/soundtouch-service_Linux_${GOARCH}"; \
    chmod +x /usr/local/bin/soundtouch-service

# Copy and install the run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]

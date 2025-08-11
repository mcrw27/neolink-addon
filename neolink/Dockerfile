ARG BUILD_FROM
FROM $BUILD_FROM

# Re-declare args after FROM
ARG BUILD_ARCH
ARG BUILD_VERSION

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies and neolink binary
RUN \
    apk add --no-cache \
        curl \
        jq \
        tzdata \
        unzip \
    && case "${BUILD_ARCH}" in \
        aarch64) NEOLINK_ARCH="arm64" ;; \
        armhf|armv7) NEOLINK_ARCH="armv7" ;; \
        amd64) NEOLINK_ARCH="x86_64" ;; \
        i386) NEOLINK_ARCH="i686" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
       esac \
    && curl -J -L -o /tmp/neolink.zip \
        "https://github.com/QuantumEntangledAndy/neolink/releases/download/v0.6.3.rc.2/neolink_linux_${NEOLINK_ARCH}.zip" \
    && unzip /tmp/neolink.zip -d /tmp/ \
    && cp /tmp/neolink_linux_${NEOLINK_ARCH}/neolink /usr/local/bin/neolink \
    && chmod +x /usr/local/bin/neolink \
    && rm -rf /tmp/neolink.zip /tmp/neolink_linux_${NEOLINK_ARCH}

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Labels
LABEL \
    io.hass.name="Neolink" \
    io.hass.description="An RTSP bridge for Reolink IP cameras" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Home Assistant Community Add-ons" \
    org.opencontainers.image.title="Neolink" \
    org.opencontainers.image.description="An RTSP bridge for Reolink IP cameras" \
    org.opencontainers.image.source="https://github.com/QuantumEntangledAndy/neolink" \
    org.opencontainers.image.licenses="MIT"

CMD [ "/run.sh" ]
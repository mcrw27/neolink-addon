ARG BUILD_FROM
ARG BUILD_ARCH
ARG BUILD_VERSION
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies and neolink binary
RUN \
    apk add --no-cache \
        curl \
        jq \
        tzdata \
    && case "${BUILD_ARCH}" in \
        aarch64) NEOLINK_ARCH="arm64" ;; \
        armhf|armv7) NEOLINK_ARCH="arm" ;; \
        amd64) NEOLINK_ARCH="amd64" ;; \
        i386) NEOLINK_ARCH="386" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
       esac \
    && curl -J -L -o /tmp/neolink.tar.gz \
        "https://github.com/thirtythreeforty/neolink/releases/latest/download/neolink-linux-${NEOLINK_ARCH}.tar.gz" \
    && tar -xzf /tmp/neolink.tar.gz -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/neolink \
    && rm /tmp/neolink.tar.gz

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
    org.opencontainers.image.source="https://github.com/home-assistant/addons" \
    org.opencontainers.image.licenses="MIT"

CMD [ "/run.sh" ]
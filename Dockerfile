ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN \
    apk add --no-cache \
        curl \
        jq \
        tzdata \
    && curl -J -L -o /tmp/neolink.tar.gz \
        "https://github.com/thirtythreeforty/neolink/releases/latest/download/neolink-linux-$(uname -m).tar.gz" \
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
#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

set -e

bashio::log.info "Starting Neolink..."

CONFIG_PATH=/data/options.json
NEOLINK_CONFIG_PATH=/tmp/neolink.toml

# Read configuration
CAMERAS=$(bashio::config 'cameras')
BIND=$(bashio::config 'bind')
DEBUG=$(bashio::config 'debug')

# Create neolink configuration
cat > "${NEOLINK_CONFIG_PATH}" <<EOF
bind = "${BIND}"
EOF

# Add debug configuration if enabled
if bashio::config.true 'debug'; then
    echo 'debug = true' >> "${NEOLINK_CONFIG_PATH}"
fi

# Process cameras configuration
if bashio::config.has_value 'cameras'; then
    for camera in $(bashio::config 'cameras | keys[]'); do
        NAME=$(bashio::config "cameras[${camera}].name")
        UID=$(bashio::config "cameras[${camera}].uid")
        PASSWORD=$(bashio::config "cameras[${camera}].password")
        ADDRESS=$(bashio::config "cameras[${camera}].address")
        
        bashio::log.info "Adding camera: ${NAME}"
        
        cat >> "${NEOLINK_CONFIG_PATH}" <<EOF

[[cameras]]
name = "${NAME}"
username = "${UID}"
password = "${PASSWORD}"
address = "${ADDRESS}"

EOF
        
        # Add streams if configured
        if bashio::config.has_value "cameras[${camera}].streams"; then
            for stream in $(bashio::config "cameras[${camera}].streams | keys[]"); do
                STREAM_NAME=$(bashio::config "cameras[${camera}].streams[${stream}].name")
                CHANNEL=$(bashio::config "cameras[${camera}].streams[${stream}].channel")
                FORMAT=$(bashio::config "cameras[${camera}].streams[${stream}].format")
                
                cat >> "${NEOLINK_CONFIG_PATH}" <<EOF
[[cameras.streams]]
name = "${STREAM_NAME}"
channel = ${CHANNEL}
format = "${FORMAT}"

EOF
            done
        fi
    done
fi

# Display configuration for debugging
if bashio::config.true 'debug'; then
    bashio::log.debug "Neolink configuration:"
    cat "${NEOLINK_CONFIG_PATH}"
fi

# Start neolink
exec neolink rtsp --config="${NEOLINK_CONFIG_PATH}"
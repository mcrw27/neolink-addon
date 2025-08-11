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

# Add MQTT configuration if enabled
if bashio::config.true 'mqtt.enabled'; then
    MQTT_BROKER=$(bashio::config 'mqtt.broker')
    MQTT_PORT=$(bashio::config 'mqtt.port')
    MQTT_USERNAME=$(bashio::config 'mqtt.username')
    MQTT_PASSWORD=$(bashio::config 'mqtt.password')
    
    bashio::log.info "Configuring MQTT: ${MQTT_BROKER}:${MQTT_PORT}"
    
    cat >> "${NEOLINK_CONFIG_PATH}" <<EOF

[mqtt]
broker_addr = "${MQTT_BROKER}"
port = ${MQTT_PORT}
EOF
    
    # Add credentials if provided
    if [[ -n "${MQTT_USERNAME}" ]]; then
        echo "credentials = [\"${MQTT_USERNAME}\", \"${MQTT_PASSWORD}\"]" >> "${NEOLINK_CONFIG_PATH}"
    fi
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
        
        # Add camera discovery if configured
        if bashio::config.has_value "cameras[${camera}].discovery"; then
            DISCOVERY=$(bashio::config "cameras[${camera}].discovery")
            echo "discovery = \"${DISCOVERY}\"" >> "${NEOLINK_CONFIG_PATH}"
        fi
        
        echo "" >> "${NEOLINK_CONFIG_PATH}"
        
        # Add MQTT discovery configuration if MQTT is enabled and discovery is true
        if bashio::config.true 'mqtt.enabled' && bashio::config.true 'mqtt.discovery'; then
            DISCOVERY_TOPIC=$(bashio::config 'mqtt.discovery_topic')
            cat >> "${NEOLINK_CONFIG_PATH}" <<EOF
[cameras.mqtt]
[cameras.mqtt.discovery]
topic = "${DISCOVERY_TOPIC}"
EOF
            
            # Add MQTT features if configured
            if bashio::config.has_value "cameras[${camera}].mqtt_features"; then
                FEATURES=$(bashio::config "cameras[${camera}].mqtt_features")
                echo "features = ${FEATURES}" >> "${NEOLINK_CONFIG_PATH}"
            fi
            
            echo "" >> "${NEOLINK_CONFIG_PATH}"
        fi
        
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
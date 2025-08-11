# Neolink Home Assistant Add-on

This add-on provides an RTSP bridge for Reolink IP cameras that use the proprietary "Baichuan" protocol (typically cameras using port 9000).

## About

Neolink allows you to use NVR software or Home Assistant to receive video streams from Reolink cameras that don't natively support RTSP. The cameras connect using their proprietary protocol, and neolink translates this into standard RTSP streams.

## Installation

1. In Home Assistant, go to **Settings** → **Add-ons** → **Add-on Store**
2. Click the **3-dot menu** (⋮) in the top right → **Repositories**
3. Add this repository URL: `https://github.com/mcrw27/neolink-addon`
4. Find and install the **Neolink** add-on
5. Configure your cameras in the add-on configuration
6. Start the add-on
7. Cameras will appear automatically (MQTT) or add RTSP streams manually

## Configuration

### Basic Configuration (RTSP Only)

```yaml
cameras:
  - name: "Front Door"
    uid: "admin"
    password: "your_password"
    address: "192.168.1.100"
    streams:
      - name: "main"
        channel: 0
        format: "h264"
      - name: "sub"
        channel: 1
        format: "h264"
bind: "0.0.0.0:8554"
debug: false
mqtt:
  enabled: false
```

### Full Configuration with MQTT Auto-Discovery

```yaml
cameras:
  - name: "Front Door"
    uid: "admin"
    password: "your_password"
    address: "192.168.1.100"
    discovery: "mqtt"
    mqtt_features: ["Camera", "Motion", "Battery", "ir"]
    streams:
      - name: "main"
        channel: 0
        format: "h264"
bind: "0.0.0.0:8554"
debug: false
mqtt:
  enabled: true
  broker: "192.168.1.50"
  port: 1883
  username: "mqtt_user"
  password: "mqtt_password"
  discovery: true
  discovery_topic: "homeassistant"
```

### Configuration Options

| Option | Required | Description |
|--------|----------|-------------|
| `cameras` | Yes | List of camera configurations |
| `cameras[].name` | Yes | Name of the camera (used in RTSP URL) |
| `cameras[].uid` | Yes | Username for camera authentication |
| `cameras[].password` | Yes | Password for camera authentication |
| `cameras[].address` | Yes | IP address of the camera |
| `cameras[].discovery` | No | Discovery method: "local" or "mqtt" |
| `cameras[].mqtt_features` | No | MQTT features: ["Camera", "Motion", "Battery", "ir", "Floodlight"] |
| `cameras[].streams` | No | List of streams to expose |
| `cameras[].streams[].name` | Yes | Name of the stream |
| `cameras[].streams[].channel` | Yes | Channel number (usually 0 for main, 1 for sub) |
| `cameras[].streams[].format` | Yes | Video format (h264 or h265) |
| `bind` | No | Bind address for RTSP server (default: "0.0.0.0:8554") |
| `debug` | No | Enable debug logging (default: false) |
| `mqtt.enabled` | No | Enable MQTT functionality (default: false) |
| `mqtt.broker` | No* | MQTT broker IP address (*required if MQTT enabled) |
| `mqtt.port` | No | MQTT broker port (default: 1883) |
| `mqtt.username` | No | MQTT username |
| `mqtt.password` | No | MQTT password |
| `mqtt.discovery` | No | Enable Home Assistant MQTT discovery (default: true) |
| `mqtt.discovery_topic` | No | MQTT discovery topic (default: "homeassistant") |

## Usage

### RTSP Streams

Once configured and started, your cameras will be available as RTSP streams at:
```
rtsp://[HOME_ASSISTANT_IP]:8554/[CAMERA_NAME]/[STREAM_NAME]
```

For example: `rtsp://192.168.1.50:8554/Front_Door/main`

### MQTT Auto-Discovery (Recommended)

When MQTT is enabled with `discovery: true`, cameras will automatically appear in Home Assistant as:
- **Camera entities** for live video streams
- **Motion sensors** for motion detection
- **Battery sensors** (for battery cameras)
- **Switch entities** for IR/floodlight control (if supported)

No manual configuration needed - devices appear automatically in **Settings** → **Devices & Services** → **MQTT**.

### Manual Camera Setup (RTSP Only)

If not using MQTT discovery, add streams manually using the Generic Camera integration:

```yaml
camera:
  - platform: generic
    name: Front Door Camera
    stream_source: rtsp://192.168.1.50:8554/Front_Door/main
    still_image_url: rtsp://192.168.1.50:8554/Front_Door/main
```

### Available MQTT Features

Configure `mqtt_features` for each camera to enable specific functionality:
- **"Camera"**: Video stream entity
- **"Motion"**: Motion detection sensor  
- **"Battery"**: Battery level sensor (battery cameras)
- **"ir"**: IR light switch
- **"Floodlight"**: Floodlight control switch

## Supported Cameras

This add-on works with Reolink cameras that use the "Baichuan" protocol, typically:
- Battery-powered cameras (Argus series, Reolink Go, etc.)
- LTE cameras (Go, Go Plus, Go PT, Lumus)
- Some WiFi cameras that don't support native RTSP
- Cameras that use port 9000 for communication

### LTE Camera Support

LTE cameras are fully supported but require special considerations:

**✅ Compatible LTE Models:**
- Reolink Go series (Go, Go Plus, Go PT)
- Reolink Lumus
- Other battery + LTE cameras using Baichuan protocol

**⚠️ Important LTE Considerations:**

1. **Data Usage**: LTE cameras consume cellular data for:
   - Initial connection and authentication
   - MQTT messages (motion alerts, battery status)
   - RTSP streaming (**high bandwidth usage**)

2. **Battery Life**: Continuous streaming significantly reduces battery life:
   - Consider motion-triggered recording instead of 24/7 streaming
   - Use lower resolution sub-streams to conserve battery
   - Prioritize MQTT alerts over continuous video streaming

3. **Network Setup**:
   - LTE cameras need internet access to reach your MQTT broker
   - If Home Assistant is on local network, ensure MQTT broker is internet-accessible
   - May require port forwarding, VPN, or cloud MQTT broker

4. **Connection Reliability**:
   - LTE connections can be intermittent
   - Add-on automatically attempts reconnection
   - Enable debug logging to monitor connection status

**Recommended LTE Configuration:**

```yaml
cameras:
  - name: "Remote Gate"
    uid: "admin"
    password: "your_password"
    address: "192.168.1.100"  # Or camera UID for remote access
    discovery: "mqtt"
    mqtt_features: ["Camera", "Motion", "Battery"]
    streams:
      - name: "sub"  # Use sub-stream to save cellular data
        channel: 1
        format: "h264"
mqtt:
  enabled: true
  broker: "your.mqtt.broker.com"  # Use internet-accessible broker
  port: 1883
  username: "mqtt_user"
  password: "mqtt_password"
```

## Troubleshooting

1. **Camera not connecting**: Verify the IP address, username, and password
2. **No video stream**: Check if the camera supports the specified format (h264/h265)
3. **Connection issues**: Ensure the add-on can reach your cameras on the network
4. **Debug mode**: Enable debug logging to see detailed connection information

## Support

For issues specific to this add-on, please check the logs and ensure your configuration is correct. For neolink-specific issues, refer to the [neolink project](https://github.com/thirtythreeforty/neolink).
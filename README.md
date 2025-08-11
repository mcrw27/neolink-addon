# Neolink Home Assistant Add-on

This add-on provides an RTSP bridge for Reolink IP cameras that use the proprietary "Baichuan" protocol (typically cameras using port 9000).

## About

Neolink allows you to use NVR software or Home Assistant to receive video streams from Reolink cameras that don't natively support RTSP. The cameras connect using their proprietary protocol, and neolink translates this into standard RTSP streams.

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the Neolink add-on
3. Configure your cameras in the add-on configuration
4. Start the add-on
5. Add the RTSP streams to Home Assistant using the Generic Camera integration

## Configuration

### Add-on Configuration

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
```

### Configuration Options

| Option | Required | Description |
|--------|----------|-------------|
| `cameras` | Yes | List of camera configurations |
| `cameras[].name` | Yes | Name of the camera (used in RTSP URL) |
| `cameras[].uid` | Yes | Username for camera authentication |
| `cameras[].password` | Yes | Password for camera authentication |
| `cameras[].address` | Yes | IP address of the camera |
| `cameras[].streams` | No | List of streams to expose |
| `cameras[].streams[].name` | Yes | Name of the stream |
| `cameras[].streams[].channel` | Yes | Channel number (usually 0 for main, 1 for sub) |
| `cameras[].streams[].format` | Yes | Video format (h264 or h265) |
| `bind` | No | Bind address for RTSP server (default: "0.0.0.0:8554") |
| `debug` | No | Enable debug logging (default: false) |

## Usage

Once configured and started, your cameras will be available as RTSP streams at:
```
rtsp://[HOME_ASSISTANT_IP]:8554/[CAMERA_NAME]/[STREAM_NAME]
```

For example: `rtsp://192.168.1.50:8554/Front_Door/main`

### Adding to Home Assistant

Add the streams to Home Assistant using the Generic Camera integration:

```yaml
camera:
  - platform: generic
    name: Front Door Camera
    stream_source: rtsp://192.168.1.50:8554/Front_Door/main
    still_image_url: rtsp://192.168.1.50:8554/Front_Door/main
```

## Supported Cameras

This add-on works with Reolink cameras that use the "Baichuan" protocol, typically:
- Battery-powered cameras (Argus series, Reolink Go, etc.)
- Some WiFi cameras that don't support native RTSP
- Cameras that use port 9000 for communication

## Troubleshooting

1. **Camera not connecting**: Verify the IP address, username, and password
2. **No video stream**: Check if the camera supports the specified format (h264/h265)
3. **Connection issues**: Ensure the add-on can reach your cameras on the network
4. **Debug mode**: Enable debug logging to see detailed connection information

## Support

For issues specific to this add-on, please check the logs and ensure your configuration is correct. For neolink-specific issues, refer to the [neolink project](https://github.com/thirtythreeforty/neolink).
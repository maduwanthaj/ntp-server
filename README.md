# Lightweight Chrony NTP server in Docker ⏱️

A minimal, efficient Docker container running **Chrony** as an NTP server, designed for lightweight time synchronization with a customizable configuration.

## Features

- Uses **Chrony** for precise, reliable network time synchronization.
- Lightweight Alpine-based Docker image.
- Configurable logging, time sources, and client access rules.
- Health checks to ensure the NTP server is active and in sync.

## Getting Started

### Prerequisites

- Docker installed on your system.

### Build the Image

To build the Docker image locally:

```bash
docker build -t chrony-ntp-server .
```

### Running the Container

Start the NTP server container with default settings:

```bash
docker run -d --name ntp-server -p 123:123/udp chrony-ntp-server
```

This will expose port `123/udp` for NTP synchronization.

## Configuration

The container can be configured via environment variables:

| Variable           | Description                                                     | Default             |
|--------------------|-----------------------------------------------------------------|---------------------|
| `NTP_POOL`         | NTP pool to sync time from.                                     | `pool.ntp.org`      |
| `NTP_SERVER`       | Specific NTP servers to sync time from (comma-separated).       | -                   |
| `NTP_CLIENT_ALLOW` | Allowed client IP ranges (comma-separated, e.g., `192.168.0.0/24`). | `allow all`         |
| `NTP_CLIENT_DENY`  | Denied client IP ranges (comma-separated).                      | None                |
| `LOG_LEVEL`        | Set log level: `0` for informational, `1` for warnings, `2` for non-fatal errors, `3` for fatal errors. | `0` (informational) |

**Note:** Setting `NTP_POOL` will override the default pool. If both `NTP_POOL` and `NTP_SERVER` are provided, `NTP_POOL` takes precedence.

### Example Usage

Here’s an example with custom time servers and access controls:

```bash
docker run -d --name ntp-server -p 123:123/udp \
  -e NTP_SERVER="time.google.com,time.cloudflare.com" \
  -e NTP_CLIENT_ALLOW="192.168.0.0/24" \
  -e LOG_LEVEL=1 \
  chrony-ntp-server
```

## Health Check

The container includes a health check that monitors Chrony’s synchronization status. It runs every 30 seconds and fails if Chrony is not synchronized.

## Logs

You can view the Chrony log level and other activity with:

```bash
docker logs ntp-server
```

## File Structure

- **Dockerfile**: Sets up the Alpine environment, installs Chrony, and copies the startup script.
- **app.sh**: The startup script that configures Chrony based on the provided environment variables and launches Chrony in the foreground.

## License

This project is licensed under the MIT License.
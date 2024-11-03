# Lightweight Chrony NTP server in Docker ⏱️

A minimal, efficient Docker container running **Chrony** as an NTP server, designed for lightweight time synchronization with a customizable configuration.

## Features

- Uses Chrony for precise, reliable network time synchronization.
- Lightweight Alpine-based Docker image.
- Configurable logging, time sources, client access rules, and time zone.
- Health checks to ensure the NTP server is active and in sync.

## Getting Started

### Prerequisites

- Docker installed on your system.

### Build the Image

To build the Docker image locally:

```bash
docker build -t ntp-server .
```

### Running the Container

Start the NTP server container with default settings:

```bash
docker run -d --name ntp-server -p 123:123/udp ntp-server
```

This will expose port `123/udp` for NTP synchronization.

## Configuration

The container can be configured via environment variables:

| Variable           | Description                                                     | Default             |
|--------------------|-----------------------------------------------------------------|---------------------|
| `NTP_POOL`         | NTP pool to sync time from. Available options:<br>- `public`: `pool.ntp.org`<br>- `google`: `time.google.com` | `pool.ntp.org`      |
| `NTP_SERVER`       | Specific NTP servers to sync time from (comma-separated). Available options:<br>- **Cloudflare**: `time.cloudflare.com`<br>- **Google**: `time1.google.com,time2.google.com,time3.google.com,time4.google.com`<br>- **Alibaba**: `ntp1.aliyun.com,ntp2.aliyun.com,ntp3.aliyun.com,ntp4.aliyun.com` | -                   |
| `NTP_CLIENT_ALLOW` | Allowed client IP ranges (comma-separated).                     | `allow all`         |
| `NTP_CLIENT_DENY`  | Denied client IP ranges (comma-separated).                      | None                |
| `LOG_LEVEL`        | Sets the Chrony log level. Options are:<br>  - `0`: Informational (default)<br>  - `1`: Warnings<br>  - `2`: Non-fatal errors<br>  - `3`: Fatal errors | `0` (Informational) |
| `TZ`               | Set the time zone for the container. For example: `Asia/Colombo`. | UTC                 |

**Note:** Setting `NTP_POOL` will override the default pool. If both `NTP_POOL` and `NTP_SERVER` are provided, `NTP_POOL` takes precedence.

### Example Usage

Here’s an example with custom time servers, access controls, and time zone:

```bash
docker run -d --name ntp-server -p 123:123/udp \
  -e NTP_SERVER="time1.google.com,time2.google.com,time3.google.com,time4.google.com" \
  -e NTP_CLIENT_ALLOW="192.168.0.0/24" \
  -e LOG_LEVEL=1 \
  -e TZ="Asia/Colombo" \
  ntp-server
```

## Health Check

The container includes a health check that monitors Chrony’s synchronization status. It runs every 30 seconds and fails if Chrony is not synchronized.

## Logs

You can view the Chrony log level and other activity with:

```bash
docker logs --follow ntp-server
```

## File Structure

- **Dockerfile**: Sets up the Alpine environment, installs Chrony, and copies the startup script.
- **app.sh**: The startup script that configures Chrony based on the provided environment variables and launches Chrony in the foreground.

## Reference

For more details on **Chrony**, visit the [official Chrony project website](https://chrony-project.org/).

## License

This project is licensed under the MIT License.
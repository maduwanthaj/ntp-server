# Lightweight chrony NTP server in Docker ⏱️

A lightweight Docker container running chrony as an NTP server, designed for time synchronization with a customizable configuration.

## Features

- Uses chrony for precise, reliable network time synchronization.
- Lightweight Alpine-based Docker image.
- Configurable logging, time sources, client access rules, and time zone.
- Network Time Security (NTS) for secure time synchronization.
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
|:-------------------|:----------------------------------------------------------------|:--------------------|
| `NTP_POOL`         | NTP pool to sync time from.<br>Available options:<br>- Public: `pool.ntp.org`<br>- Google: `time.google.com` | `pool.ntp.org`      |
| `NTP_SERVER`       | Specific NTP servers to sync time from (comma-separated).<br>Available options:<br>- Cloudflare: `time.cloudflare.com`<br>- Google: `time1.google.com,time2.google.com,time3.google.com,time4.google.com`<br>- Alibaba: `ntp1.aliyun.com,ntp2.aliyun.com,ntp3.aliyun.com,ntp4.aliyun.com` | -                   |
| `ENABLE_NTS`       | Enable Network Time Security (NTS) for secure time synchronization.<br>Options: `true`, `false`. | `false`             |
| `NTP_CLIENT_ALLOW` | Allowed client IP ranges (comma-separated).                     | `allow all`         |
| `NTP_CLIENT_DENY`  | Denied client IP ranges (comma-separated).                      | none                |
| `LOG_LEVEL`        | Sets the chrony log level. Options are:<br>  - `0`: informational (default)<br>  - `1`: warning<br>  - `2`: non-fatal error<br>  - `3`: fatal error | `0` (informational) |
| `TZ`               | Set the time zone for the container. For example: `Asia/Colombo`. | UTC                 |

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

## Network Time Security (NTS)

Network Time Security (NTS) is an extension to NTP that provides secure authentication between NTP clients and servers, protecting against certain types of attacks such as replay or man-in-the-middle.

### Enabling NTS

To enable Network Time Security (NTS), set the `ENABLE_NTS` environment variable to `true`. Ensure that the specified NTP pool or server supports NTS for secure synchronization.

### Example Usage

Here’s an example of enabling NTS for secure time synchronization:

```bash
docker run -d --name ntp-server -p 123:123/udp \
  -e NTP_SERVER="time.cloudflare.com" \
  -e ENABLE_NTS=true \
  ntp-server
```

## Health Check

The container includes a health check that monitors chrony’s synchronization status. It runs every 30 seconds and fails if chrony is not synchronized.

## Monitoring Commands

You can monitor the NTP server status and sources with `chronyc` commands inside the running container. Here are some examples with sample outputs:

```bash
# Check tracking details to see the server’s synchronization status
docker exec ntp-server chronyc tracking
# Output example:
# Reference ID    : D8EF2304 (time2.google.com)
# Stratum         : 2
# Ref time (UTC)  : Wed Nov 01 07:00:57 2024
# System time     : 0.058912471 seconds slow of NTP time
# Last offset     : +0.001500682 seconds
# RMS offset      : 0.004327922 seconds
# Frequency       : 34.015 ppm slow
# Residual freq   : -0.522 ppm
# Skew            : 234.594 ppm
# Root delay      : 0.089301638 seconds
# Root dispersion : 0.026841348 seconds
# Update interval : 64.7 seconds
# Leap status     : Normal

# View the NTP sources currently in use
docker exec ntp-server chronyc sources
# Output example:
# MS Name/IP address         Stratum Poll Reach LastRx Last sample               
# ===============================================================================
# ^+ time1.google.com              1   6   377    23  +5004us[  +12ms] +/-   42ms
# ^* time2.google.com              1   6   377    22  -6713us[ +511us] +/-   41ms
# ^+ time3.google.com              1   6   377    23  -9773us[-2554us] +/-   49ms
# ^- time4.google.com              1   6   377    26    -14ms[-7191us] +/-   41ms

# Display source statistics, including delay, offset, and jitter
docker exec ntp-server chronyc sourcestats
# Output example:
# Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
# ==============================================================================
# time1.google.com           10   7   394    +32.307    251.895  +8188us    24ms
# time2.google.com            8   4   391    +74.260    122.911  +8660us  7923us
# time3.google.com           10   4   394    -27.592    281.163  -6798us    25ms
# time4.google.com           10   5   393    -19.958    129.320    -10ms    11ms

# List connected NTP clients
docker exec ntp-server chronyc clients
# Output example:
# Hostname                      NTP   Drop Int IntL Last     Cmd   Drop Int  Last
# ===============================================================================
# server                          2      0   6   -    70       0      0   -     -
```

These commands provide real-time information on the server's sync status, sources, and connected clients, helping you verify time synchronization details.

## Docker Compose Example

Here’s an example `docker-compose.yml` file to run the NTP server with Docker Compose:

```yaml
services:
  ntp-server:
    image: ntp-server
    container_name: ntp-server
    ports:
      - 123:123/udp
    environment:
      - NTP_SERVER=time1.google.com,time2.google.com,time3.google.com,time4.google.com
      - NTP_CLIENT_ALLOW=192.168.0.0/24
      - LOG_LEVEL=1
      - TZ=Asia/Colombo
```

To start the container with Docker Compose:

```bash
docker compose up -d
```

## Logs

You can view the chrony log level and other activity with:

```bash
docker logs --follow ntp-server
```

## File Structure

- **Dockerfile**: Sets up the Alpine environment, installs chrony, and copies the startup script.
- **app.sh**: The startup script that configures chrony based on the provided environment variables and launches chrony in the foreground.

## Reference

For more details on `chrony`, visit the [official chrony project website](https://chrony-project.org/).

## License

This project is licensed under the MIT License.
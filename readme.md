### Code blocks
> install chrony and tzdata
```sh
apk add --no-cache chrony tzdata
```

> if environment variable does not exist, stores a default variable
```sh
Var="${DEPLOY_ENV:-default_value}"
```


### Gound knowledge
> chrony directories
- `/run/chrony`: Holds runtime data for the chronyd process.
- `/etc/chrony/chrony.conf`: The main configuration file to set up NTP synchronization.
- `/var/lib/chrony/chrony.drift`: Stores the drift value to improve the accuracy of timekeeping.


### chrony default configuration file
```plaintext
/etc/chrony/chrony.conf 
pool pool.ntp.org iburst
initstepslew 10 pool.ntp.org
driftfile /var/lib/chrony/chrony.drift
rtcsync #Tells Chrony to synchronize the system's hardware clock (RTC - Real Time Clock) with the system clock.
cmdport 0 #Chrony will not listen for commands from clients over a network socket
```


### NTP servers
```plaintext
^ cloudflare
time.cloudflare.com
^ google
time1.google.com,time2.google.com,time3.google.com,time4.google.com
^ alibaba
ntp1.aliyun.com,ntp2.aliyun.com,ntp3.aliyun.com,ntp4.aliyun.com
^ local (offline)
127.127.1.1
```


### NTP pool
```plaintext
^ pubic
pool.ntp.org
^ google
time.google.com
```


### References
https://chrony-project.org/index.html
https://www.ntppool.org/en/
https://hub.docker.com/r/cturra/ntp
https://github.com/cturra/docker-ntp/tree/main


### Docker run commands
```bash
docker run -d \
-e TZ=Asia/Colombo \
-p 123:123/udp \
--name ntp-server \
--restart always \
time-server:latest

docker run -d \
-e TZ=Asia/Colombo \
-e LOG_LEVEL=3 \
-p 123:123/udp \
--name ntp-server \
--restart always \
time-server:latest

docker run -d \
-e TZ=Asia/Colombo \
-e NTP_POOL="time.google.com" \
-p 123:123/udp \
--name ntp-server \
--restart always \
time-server:latest

docker run -d \
-e TZ=Asia/Colombo \
-e NTP_SERVER="time1.google.com,time2.google.com,time3.google.com,time4.google.com" \
-p 123:123/udp \
--name ntp-server \
--restart always \
time-server:latest

docker run -d \
-e TZ=Asia/Colombo \
-e NTP_SERVER="time1.google.com,time2.google.com,time3.google.com,time4.google.com" \
-e NTP_CLIENT_ALLOW="192.168.10.1,192.168.8.0/24,192.168.10.100" \
-p 123:123/udp \
--name ntp-server \
--restart always \
time-server:latest

docker run -d \
-e TZ=Asia/Colombo \
-e NTP_SERVER="time1.google.com,time2.google.com,time3.google.com,time4.google.com" \
-e NTP_CLIENT_ALLOW="192.168.10.1,192.168.8.0/24,192.168.10.100" \
-e NTP_CLIENT_DENY="192.168.8.100,192.168.8.200,192.168.10.1" \
-p 123:123/udp \
--name ntp-server \
--restart always \
time-server:latest
```


### Environment variables
```sh
NTP_CLIENT_ALLOW="192.168.10.1,192.168.8.0/24"
NTP_CLIENT_DENY="192.168.10.1,192.168.8.0/24"
LOG_LEVEL="1"   # 0 (informational), 1 (warning), 2 (non-fatal error), and 3 (fatal error). The default value is 0.
NTP_SERVER="time1.google.com,time2.google.com,time3.google.com,time4.google.com"
NTP_POOL="pool.ntp.org"
TZ="Asia/Colombo"
```


### Next steps
(1) Adding different NTP server/pool --- OK
(2) Secure NTP
(3) Allow/deny NTP clients --- OK
(4) Change log level --- OK
(5) Show NTP client connections when connected
(6) Add HEALTHCHECK instruction to the Dockerfile --- OK
(7) Optimizing the script
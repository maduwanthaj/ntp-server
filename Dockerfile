FROM alpine

# install chrony, tzdata, and create the application directory
RUN apk add --no-cache chrony tzdata && \
    mkdir /app

# set the working directory
WORKDIR /app

# copy the script to the working directory and make it executable
COPY app.sh .
RUN chmod +x app.sh

# expose the NTP port for time synchronization
EXPOSE 123/udp

# check if chronyd is active and in sync; if not, mark the container as unhealthy
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s CMD chronyc tracking || exit 1

# run the startup script as the container's entrypoint
ENTRYPOINT [ "./app.sh" ]
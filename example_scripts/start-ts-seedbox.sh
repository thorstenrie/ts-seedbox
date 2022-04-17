#!/bin/sh

# Build container image
podman build --pull --no-cache  -t rt_client ../rt_client/

# Start pod
podman pod create \
    --name ts_seedbox_pod \
    --publish 50000:50000 \
    --publish 6881:6881 \
    --publish 6881:6881/udp

# Start container
podman run --rm -d \
    --pod ts_seedbox_pod \
    --volume rtorrent_session:/home/rtorrent/rtorrent/.session \
    --volume "$TS_RT_CLIENT_HOME"/download:/home/rtorrent/rtorrent/download \
    --name rt_clt \
    rt_client

# Wait to let rtorrent client start
sleep 5s

# Get rtorrent client status
podman logs -f rt_clt

#!/bin/sh

# Build container image
sudo podman build --pull --no-cache  -t rt_client ../rt_client/

# Start pod
sudo podman pod create \
    --name ts_seedbox_pod \
    --uidmap 0:"$TS_USERNS_RT":65536 \
    --gidmap 0:"$TS_USERNS_RT":65536 \
    --publish 50000:50000 \
    --publish 6881:6881 \
    --publish 6881:6881/udp

# Start container
sudo podman run --rm -d \
    --pod ts_seedbox_pod \
    --volume "$TS_RT_CLIENT_HOME"/session:/home/rtorrent/rtorrent/.session \
    --volume "$TS_RT_CLIENT_HOME"/download:/home/rtorrent/rtorrent/download \
    --name rt_clt \
    rt_client

# Wait to let rtorrent client start
sleep 7s

# Get rtorrent client status
sudo podman logs -f rt_clt

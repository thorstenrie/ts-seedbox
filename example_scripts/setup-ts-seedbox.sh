#!/bin/sh

# Do only once: create volume host directories (only needed first time on host)
sudo mkdir -p "$TS_RT_CLIENT_HOME"/download

# Do only once: Setup rtorrent user (only needed first time on host)
sudo groupadd -r --gid 667 rtorrent
sudo useradd -r --uid 667 --gid 667 -s /usr/bin/nologin rtorrent
sudo chown 667:667 "$TS_RT_CLIENT_HOME"/download

#!/bin/sh

# Do only once: create volume host directories (only needed first time on host)
sudo mkdir -p "$TS_RT_CLIENT_HOME"/download
sudo mkdir "$TS_RT_CLIENT_HOME"/session

# Do only once: Setup rtorrent user (only needed first time on host)
sudo groupadd -r --gid "$TS_UGID_RT" rtorrent
sudo useradd -r --uid "$TS_UGID_RT" --gid "$TS_UGID_RT" -s /usr/bin/nologin rtorrent
sudo chown -R "$TS_UGID_RT":"$TS_UGID_RT" "$TS_RT_CLIENT_HOME"

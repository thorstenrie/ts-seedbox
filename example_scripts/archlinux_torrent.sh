#!/bin/sh

SCRIPT_FILE=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT_FILE")

TORRENT_ARCH_FILE="$SCRIPT_PATH/archlinux.iso.torrent"

curl https://archlinux.org/releng/releases/$(date +'%Y.%m.01')/torrent/ --output "$TORRENT_ARCH_FILE"

podman cp "$TORRENT_ARCH_FILE" rt_clt:/home/rtorrent/rtorrent/watch/start

printf "Total %i files with size %s in rtorrent download directory \"%s\".\n" $(ls "$RT_CLIENT_HOME"/download | wc -l) $(du -sh "$RT_CLIENT_HOME" | awk '{print $1}') "$RT_CLIENT_HOME"

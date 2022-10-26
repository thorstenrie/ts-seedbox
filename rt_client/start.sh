#!/bin/sh

# Launch rtorrent as background process
nohup bash -c "rtorrent" &

# Wait for 5s to let rtorrent spin up
sleep 5s

# Change directory to log directory
cd /home/rtorrent/rtorrent/log

# Output appended log messages from latest log file
tail -f `ls -tr | tail -n 1`

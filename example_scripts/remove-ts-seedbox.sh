#!/bin/sh

# Make sure to stop ts-seedbox before removing it.

# Remove pod
sudo podman pod rm ts_seedbox_pod

# Remove container (not needed with --rm option when using podman run)
sudo podman container rm rt_clt

# Remove container images
sudo podman rmi archlinux
sudo podman rmi rt_client

# Remove rtorrent volume (only needed for testing to start from scratch)
sudo podman volume rm rtorrent_session

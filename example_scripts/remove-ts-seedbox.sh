#!/bin/sh

# Make sure to stop ts-seedbox before removing it.

# Remove pod
podman pod rm ts_seedbox_pod

# Remove container (not needed with --rm option when using podman run)
podman container rm rt_client

# Remove container images
podman rmi archlinux
podman rmi rt_client

# Remove rtorrent volume (only needed for testing to start from scratch)
podman volume rm rtorrent_session

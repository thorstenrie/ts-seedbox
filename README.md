# ts-seedbox
[RTorrent](https://github.com/rakshasa/rtorrent/wiki), [Archlinux](https://archlinux.org/) and [Podman](https://podman.io/) based container seedbox that tries to keep it simple ([KISS principle](https://en.wikipedia.org/wiki/KISS_principle)). One purpose could be to support distributing free software if you can spare server and bandwidth ressources (e.g., [Archlinux](https://archlinux.org/download/)). After network and container set up is completed, just put torrent files into the container's *watch/start* directory and the file will be downloaded to the host *download* directory.

- **Security**: rTorrent is run from a non-root system user
- **Functionality**: Pre-configured for use on a home/self-hosted server
- **Easy setup**: Use the example shell scripts for an easy start to launch the container and start downloading and seeding

Two options to get it running:

- **Quick Start Guide**: Run the container with minimal effort by using provided example scripts
*(Warning: only recommended for development environments!)*
- **Setup Guide**: Follow each step of the setup guide

## Prerequisites

[Podman](https://podman.io/), a x86-64 Linux system and root access to it is required.

## Network Setup

To run properly, two ports are needed: 

- `Port 50000`: Listening port for incoming peer traffic (TCP)
- `Port 6881`: DHT for storing peer contact information for "trackerless" torrents (TCP and UDP)

Both ports need to be opened and forwarded in router and firewall with their corresponding protocols (TCP and/or UDP). Check your hardware and software documentations on how to open and forward ports. For example, if you use [ufw](https://launchpad.net/ufw) as firewall, you could run as root

    # ufw route allow proto tcp to any port 50000
    # ufw route allow proto tcp to any port 6881
    # ufw route allow proto udp to any port 6881

Additionally, both ports need to be published with the container or pod. With [podman-run](https://docs.podman.io/en/latest/markdown/podman-run.1.html) and [podman-pod-create](https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html), this can be done by using the `--publish` flag.

## Quick Start with Example Scripts

> Use the example scripts only in development environments. The scripts create directories and a non-root system user, therefore changes the system.

> Most commands need root user rights, e.g., you can precede commands with `sudo`

1. Configure a new environment variable $TS_RT_CLIENT_HOME pointing to the directory where the downloaded files will be stored, e.g., 

        $ export TS_RT_CLIENT_HOME=/srv/rtorrent

2. Run the setup script once to set up your system by creating the download directory, non-root system user and group `rtorrent` with `UID 667` and `GID 667`

        # ./setup-ts-seedbox.sh
        
3. Run the start script to start a pod, the container and open the log output. A volume for session data is created and the download directory is mounted into the container

        # ./start-ts-seedbox.sh
        
4. Optional: To start downloading the latest Archlinux image, run

        # ./archlinux_torrent.sh
        
5. To stop the pod and container, execute

        # ./stop-ts-seedbox.sh
        
6. To remove all images and the volume for the session data, you can run

        # ./remove-ts-seedbox.sh
        
## Step by Step Container Setup

## Configuration & Maintainance

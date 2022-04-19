# ts-seedbox
[RTorrent](https://github.com/rakshasa/rtorrent/wiki) and [Archlinux](https://archlinux.org/) based seedbox container that tries to keep it simple ([KISS principle](https://en.wikipedia.org/wiki/KISS_principle)). One purpose could be to support distributing free software if you can spare server and bandwidth ressources (e.g., [Archlinux](https://archlinux.org/download/)). After the network and container setup is completed, just put torrent files into the container's *watch/start* directory and the file will be downloaded to the host *download* directory and continued to be seeded.

- **Security**: rTorrent is run from a non-root system user
- **Functionality**: rTorrent is pre-configured for use on a home/self-hosted server
- **Easy setup**: Use the example shell scripts for an easy start to launch the container and start downloading and seeding

Clone the git repository with:

    git clone https://github.com/Licht-Protoss/ts-seedbox.git

Three options to get it running:

- **Build & run with the Quick Start Guide**: Run the container with minimal effort by using provided example scripts
*(Warning: only recommended for development environments!)*
- **Build & run with the Setup Guide**: Follow each step of the setup guide and adapt it to your needs
- **Directly pull the container image**: Follow the Readme on [docker.io/lichtprotoss/ts-seedbox](https://hub.docker.com/repository/docker/lichtprotoss/ts-seedbox) (container building not needed)

## Prerequisites

The container is build and tested with [Podman](https://podman.io/). To complete the guide, [Podman](https://podman.io/) on a x86-64 Linux system and root access is required.

The container is expected to also run with Docker. To complete the guide with Docker, adaptations are needed.
- To build the container image with Docker: Rename [Containerfile](https://github.com/Licht-Protoss/ts-seedbox/blob/main/rt_client/Containerfile) to `Dockerfile` and [substitute](https://podman.io/whatis.html) `podman` commands with `docker` commands. Further adaptations may be necessary.
- To complete the guide and run the container with docker: [Substitute](https://podman.io/whatis.html) the `podman` commands with `docker` commands, omit the [podman pod create](https://docs.podman.io/en/latest/markdown/podman-pod-create.1.html) command, instead add the `--publish` flags to the `docker run` command. Further adaptations may be necessary.

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

> Use the example scripts with caution and only in a development environment. The scripts create directories and a non-root system user, therefore change the host system.

> Requires `sudo`: Some commands need root user rights and therefore are preceded with `sudo`

> It is recommended to check the scripts before executing them to prevent unwanted behavior

1. Change your current directory to `example-scripts`

        $ cd example-scripts

1. Configure a new environment variable `$TS_RT_CLIENT_HOME` pointing to the directory where the downloaded files will be stored, e.g., 

        $ export TS_RT_CLIENT_HOME=/srv/rtorrent

2. Run the setup script once to set up your system by creating the download directory, non-root system user and group `rtorrent` with `UID 667` and `GID 667`

        $ ./setup-ts-seedbox.sh
        
3. Run the start script to start a pod, the container and open the log output. A volume for session data is created and the download directory is mounted into the container

        $ ./start-ts-seedbox.sh
        
4. Optional: To start downloading the latest Archlinux image, run

        $ ./archlinux_torrent.sh
        
5. To stop the pod and container, execute

        $ ./stop-ts-seedbox.sh
        
6. To remove all images and the volume for the session data, you can run

        $ ./remove-ts-seedbox.sh
        
## Setup Guide & Execution

### Download directory

The download directory is a bind mount mapping the download directory in the container a defined download directory on the host system. Therefore, a download directory needs to be created in the container and in the host system.

- For the container, the directory will be automatically created in the container build
- For the host system, you need to define and create it by yourself.

First, create an environment variable, holding the host system download directory path, e.g., `/srv/rtorrent`

        $ export TS_RT_CLIENT_HOME=/srv/rtorrent

Afterwards, create the directory

        # mkdir -p "$TS_RT_CLIENT_HOME"/download
        
### rTorrent session data

The rTorrent session data should be stored in the host system. This enables to keep session data in case the container is stopped or removed and is launched again afterwards. Therefore, the named volume `rtorrent_session` is created when running the container the first time (see below). Afterwards, the named volume will be used for following executions of the container.

### Non-root system user

Within the container, the rtorrent client will be executed by a non-root system user with username `rtorrent`, `UID 667` in group `rtorrent`, `GID 667`. The user is also required to be existent on the host system to actually store downloaded files in the bind mount.

- For the container, the user will be automatically created in the container build
- For the host system, you need to create the user, group and change the owner of `$TS_RT_CLIENT_HOME`

To create the group and user, run

    # groupadd -r --gid 667 rtorrent
    # useradd -r --uid 667 --gid 667 -s /usr/bin/nologin rtorrent
    
Next, change the owner of `$TS_RT_CLIENT_HOME` to the new user

    # chown 667:667 "$TS_RT_CLIENT_HOME"/download

### Build container image

The container image `rt_client` is build with [podman-build](https://docs.podman.io/en/latest/markdown/podman-build.1.html). With the flags `--pull` and `--no-cache` we explicitely require the base image to be pulled from the registry and build from start.

    # podman build --pull --no-cache  -t rt_client ./rt_client/
    
### Create pod

The container will be launched in a pod [1](https://kubernetes.io/docs/concepts/workloads/pods/) [2](https://developers.redhat.com/blog/2019/01/15/podman-managing-containers-pods). Here, we will create a new pod named `ts_seedbox_pod`. To enable the rtorrent client in the container to use the required ports, they have to be published to the host.

    # podman pod create \
        --name ts_seedbox_pod \
        --publish 50000:50000 \
        --publish 6881:6881 \
        --publish 6881:6881/udp

### Launch container

With [podman-run](https://docs.podman.io/en/latest/markdown/podman-run.1.html), the rtorrent client is launched in container `rt_clt` in pod `ts_seedbox_pod`. With the `--volume` flags, the download directory bind mount and named session data volume are used. With `--rm` the container will be removed when it exits.

    # podman run --rm -d \
        --pod ts_seedbox_pod \
        --volume rtorrent_session:/home/rtorrent/rtorrent/.session \
        --volume "$TS_RT_CLIENT_HOME"/download:/home/rtorrent/rtorrent/download \
        --name rt_clt \
        rt_client
        
### Get rTorrent status

The log of the rtorrent client can be viewed with [podman-logs](https://docs.podman.io/en/latest/markdown/podman-logs.1.html)

    # podman logs -f rt_clt
    
### Start torrent

A torrent is started by copying a `.torrent` file to the directory in the container `/home/rtorrent/rtorrent/watch/start`. As example, you could start by downloading the [Archlinux Image](https://archlinux.org/download/).

First, download the latest Archlinux `.torrent` file

    $ curl https://archlinux.org/releng/releases/$(date +'%Y.%m.01')/torrent/ --output archlinux.iso.torrent
    
Next, copy the `.torrent` file into the start directory in the container

    # podman cp archlinux.iso.torrent rt_clt:/home/rtorrent/rtorrent/watch/start
    
The rtorrent client in the container will automatically start downloading. After the download is completed, it is seeded to other clients.

### Stop container

The container can be stopped by stopping containers in the `ts_seedbox_pod` with [podman-pod-stop](https://docs.podman.io/en/latest/markdown/podman-pod-stop.1.html)

    # podman pod stop ts_seedbox_pod
    
### Remove all 

The following commands remove the pod, container, container images and named session data volume.

    # podman pod rm ts_seedbox_pod
    # podman container rm rt_clt
    # podman rmi archlinux
    # podman rmi rt_client
    # podman volume rm rtorrent_session

## Configuration & Maintainance

- To see the size and number of downloaded files, you could use

        # printf "Total %i files with size %s in rtorrent download directory \"%s\".\n" $(ls "$TS_RT_CLIENT_HOME"/download | wc -l) $(du -sh "$TS_RT_CLIENT_HOME" | awk '{print $1}') "$TS_RT_CLIENT_HOME"
        
- The rTorrent configuration is based on the original [Config Template](https://github.com/rakshasa/rtorrent/wiki/CONFIG-Template)

- The rTorrent configuration can be found in the files in `rt_client/config.d/`

- Updating the configuration requires adapting the configuration files and re-building the container image.

- Global upload and download rate limits are set in `rt_client/config.d/4_perf.rc`

- In the sense of a rolling-release model, it is recommended to rebuild the container image frequently, e.g., based on time periods, like weekly, or every time it is launched. This ensures that the container stays up-to-date with latest updates making full use of the rolling-release model of Archlinux.

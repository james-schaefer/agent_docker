#!/bin/bash

# Grant local X server access to Docker containers.
# This is the permissive approach suitable for a trusted local machine.
xhost +local:docker

# Ensure the Pi config dir exists on the host so the bind-mount below
# doesn't get auto-created as root-owned by the Docker daemon.
mkdir -p /home/schaefer/.pi/agent
mkdir -p /home/schaefer/.claude/

docker run -it \
  --name agent-dev \
  --hostname agent-dev \
  --network host \
  --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /home/schaefer/docker_bridge:/home/schaefer/docker_bridge \
  -v /home/schaefer/.pi:/home/schaefer/.pi \
  -v /home/schaefer/.claude:/home/schaefer/.claude \
  agent-dev

# Revoke access after the container exits
xhost -local:docker

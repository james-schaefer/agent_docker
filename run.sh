#!/bin/bash

# Grant local X server access to Docker containers.
# This is the permissive approach suitable for a trusted local machine.
xhost +local:docker

docker run -it \
  --name agent-dev \
  --network host \
  --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /home/schaefer/docker_bridge:/home/schaefer/docker_bridge \
  agent-dev

# Revoke access after the container exits
xhost -local:docker

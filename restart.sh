#!/bin/bash

# Re-grant X server access and restart the existing container.
xhost +local:docker

docker restart agent-dev

# Revoke access after the container exits
xhost -local:docker

#!/bin/bash

# Re-grant X server access and restart the existing container.
xhost +local:docker

docker restart agent-dev

# Note: xhost is NOT revoked here because docker restart is non-blocking.
# Access will be revoked when the container is next stopped via run.sh.

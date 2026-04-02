#!/usr/bin/env bash
set -euo pipefail

if docker ps -a --format '{{.Names}}' | grep -Fxq agent-dev.old; then
  if docker ps --format '{{.Names}}' | grep -Fxq agent-dev.old; then
    docker exec -it agent-dev.old bash -l
  else
    docker start -ai agent-dev.old
  fi
else
  docker run -it \
    --hostname agent-dev.old \
    --name agent-dev.old \
    -v /home/schaefer/docker_bridge:/home/schaefer/docker_bridge \
    agent-dev.old:latest
fi

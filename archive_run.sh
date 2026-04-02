#!/usr/bin/env bash
set -euo pipefail

if docker ps -a --format '{{.Names}}' | grep -Fxq claude-dev.old; then
  if docker ps --format '{{.Names}}' | grep -Fxq claude-dev.old; then
    docker exec -it claude-dev.old bash -l
  else
    docker start -ai claude-dev.old
  fi
else
  docker run -it \
    --hostname claude-dev.old \
    --name claude-dev.old \
    -v /home/schaefer/docker_bridge:/home/schaefer/docker_bridge \
    claude-dev.old:latest
fi

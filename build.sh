#!/bin/bash

# Default: layer caching enabled (fast incremental builds)
# Pass --no-cache to force a full rebuild from scratch
CACHE=""
if [ "${1:-}" = "--no-cache" ]; then
  CACHE="--no-cache"
fi

docker build \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  --progress=plain \
  $CACHE \
  -t agent-dev . 2>&1 | tee build.log
#!/usr/bin/env bash
set -euo pipefail

if docker ps --format '{{.Names}}' | grep -Fxq agent-dev; then
  docker stop agent-dev
fi

if docker ps -a --format '{{.Names}}' | grep -Fxq agent-dev.old; then
  docker rm -f agent-dev.old
fi

if docker ps -a --format '{{.Names}}' | grep -Fxq agent-dev; then
  docker rename agent-dev agent-dev.old
fi

if docker image inspect agent-dev.old:latest >/dev/null 2>&1; then
  docker image rm agent-dev.old:latest
fi

if docker image inspect agent-dev:latest >/dev/null 2>&1; then
  docker tag agent-dev:latest agent-dev.old:latest
  docker image rm agent-dev:latest
fi

if [ -e build.log ]; then
  mv -f build.log build.log.old
fi

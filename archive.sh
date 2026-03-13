#!/usr/bin/env bash
set -euo pipefail

if docker ps --format '{{.Names}}' | grep -Fxq claude-dev; then
  docker stop claude-dev
fi

if docker ps -a --format '{{.Names}}' | grep -Fxq claude-dev.old; then
  docker rm -f claude-dev.old
fi

if docker ps -a --format '{{.Names}}' | grep -Fxq claude-dev; then
  docker rename claude-dev claude-dev.old
fi

if docker image inspect claude-dev.old:latest >/dev/null 2>&1; then
  docker image rm claude-dev.old:latest
fi

if docker image inspect claude-dev:latest >/dev/null 2>&1; then
  docker tag claude-dev:latest claude-dev.old:latest
  docker image rm claude-dev:latest
fi

if [ -e build.log ]; then
  mv -f build.log build.log.old
fi

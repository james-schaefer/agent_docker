#!/bin/bash

docker build --no-cache \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  --progress=plain \
  -t agent-dev . 2>&1 | tee build.log

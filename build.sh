docker build \
  --build-arg USER_UID=$(id -u) \
  --build-arg USER_GID=$(id -g) \
  --progress=plain \
  --no-cache \
  -t claude-dev . 2>&1 | tee build.log

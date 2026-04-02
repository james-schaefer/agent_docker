#!/bin/bash

# Open an additional bash shell inside the already-running container.
# The container must have been started with run.sh first.
docker exec -it agent-dev bash -l

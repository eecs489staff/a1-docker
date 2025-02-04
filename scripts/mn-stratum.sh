#!/bin/bash

MN_STRATUM_DOCKER_NAME=${MN_STRATUM_DOCKER_NAME:-eecs489-mn-stratum}
MN_STRATUM_IMG=${MN_STRATUM_IMG:-opennetworking/mn-stratum:20.12}
MN_STRATUM_MOUNT_DIR=${MN_STRATUM_MOUNT_DIR:-$PWD}

docker run --privileged --rm -it \
  --name $MN_STRATUM_DOCKER_NAME \
  --network host \
  -v /tmp/mn-stratum:/tmp \
  -v "$MN_STRATUM_MOUNT_DIR":/workdir -w /workdir \
  $MN_STRATUM_IMG "$@"

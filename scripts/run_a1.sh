#!/bin/bash
MN_STRATUM_489_IMG=${MN_STRATUM_489_IMG:-ahzhang/eecs489a1:dev}
MN_STRATUM_MOUNT_DIR=${MN_STRATUM_MOUNT_DIR:-$PWD}

stop_container() {
  sudo docker stop $(sudo docker ps -q --filter ancestor=$MN_STRATUM_489_IMG)
  sudo mn -c
}
trap 'stop_container;' EXIT

sudo docker run -it --rm --privileged \
    --network host \
    --name eecs489a1 \
    -v /tmp/mn-stratum:/tmp \
    -v "$MN_STRATUM_MOUNT_DIR":/workdir -w /workdir \
    $MN_STRATUM_489_IMG
# sudo docker run -it --rm --privileged -v "$PWD":~/host_mount ahzhang/eecs489a1:dev

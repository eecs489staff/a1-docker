#!/bin/bash

ONOS_DOCKER_NAME=${ONOS_DOCKER_NAME:-eecs489-onos}
ONOS_IMG=${ONOS_IMG:-onosproject/onos:2.2.2}

stop_container() {
  sudo docker stop $(sudo docker ps -q --filter ancestor=$ONOS_IMG)
}
trap 'stop_container;' EXIT

docker run -it --rm \
  --name $ONOS_DOCKER_NAME \
  -e ONOS_APPS \
  --network host \
  -p 8101:8101 \
  -v /tmp/onos:/root/onos/apache-karaf-4.2.8/data/tmp \
  $ONOS_IMG "$@"

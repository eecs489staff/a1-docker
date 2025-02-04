#!/bin/bash

ONOS_CLI_DOCKER_NAME=${ONOS_CLI_DOCKER_NAME:-eecs489-onos-cli}
ONOS_CLI_IMG=${ONOS_CLI_IMG:-davidlor/python-ssh}

stop_container() {
  sudo docker stop $(sudo docker ps -q --filter ancestor=$ONOS_CLI_IMG)
}
trap 'stop_container;' EXIT

docker run -it --rm \
  --name $ONOS_CLI_DOCKER_NAME \
  --network host \
  $ONOS_CLI_IMG ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p 8101 onos@localhost

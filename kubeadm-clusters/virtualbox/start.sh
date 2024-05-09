#!/bin/bash

HOST_PORT=${1:-8080}

if (( HOST_PORT < 1024 )); then
  echo "Error: Ports less than 1024 are restricted. Please choose a port higher than 1024."
  exit 1
fi

# change setup-localhost script if you don`t use apt package manager...
sudo ./k8s/setup-localhost.sh "adminer.k8s.com, kanban.k8s.com" $HOST_PORT

vagrant destroy -f
HOST_PORT=$HOST_PORT PORT_FORWARDING_TO_HOST=true SINGLE_THREAD_MODE=false vagrant up
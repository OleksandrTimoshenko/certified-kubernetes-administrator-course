#!/bin/bash

WEAVE_NETWORK_PLUGIN_VERSION=$1 # 2.8.1
NETWORK_CIDR="10.244.0.0/16"
USER="vagrant"

log_message() {
    local message="$1"
    local top_pad="="
    local len=${#message}
    for ((i = 0; i < $len; i++)); do
        top_pad+="="
    done
    echo $top_pad 
    echo = $message = 
    echo $top_pad
}

log_message "Setup Pod networking (weave)"
wget https://github.com/weaveworks/weave/releases/download/v${WEAVE_NETWORK_PLUGIN_VERSION}/weave-daemonset-k8s.yaml -O weave.yaml
sudo chown $USER weave.yaml

# add CIDR setup to weave network definition
sed -i -e "/- name: INIT_CONTAINER/i\\
                - name: IPALLOC_RANGE\\
                  value: $NETWORK_CIDR" weave.yaml

sudo -H -u $USER bash -c "kubectl apply -f weave.yaml"

log_message "Use this command on wokrers to connect it to this k8s cluster:"
echo "sudo $(kubeadm token create --print-join-command)"
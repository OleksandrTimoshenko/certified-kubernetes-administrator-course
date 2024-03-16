#!/bin/bash

BUILD_MODE=$1 # BRIDGE or NAT
NETWORK=$2    # enp0s8
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

log_message "Getting Master IP"
# Export internal IP of primary NIC as an environment variable
if [ "$BUILD_MODE" = "BRIDGE" ]
then
    PRIMARY_IP=$(ip route | grep "^default.*${NETWORK}" | awk '{ print $9 }')
else
    PRIMARY_IP=$(ip route | grep default | awk '{ print $9 }')
fi

log_message "Master IP: $PRIMARY_IP"

log_message "Create cluster"
sudo kubeadm init --pod-network-cidr=$NETWORK_CIDR --apiserver-advertise-address=$PRIMARY_IP
mkdir -p /home/$USER/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/$USER/.kube/config
sudo chown $(id -u $USER):$(id -g $USER) /home/$USER/.kube/config

log_message "Testing..."
sleep 10
sudo -H -u $USER bash -c "kubectl get pods"

log_message "Setup Pod networking (weave)"
wget wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml -O weave.yaml
sudo chown $USER weave.yaml

# add CIDR setup to weave network definition
sed -i -e "/- name: INIT_CONTAINER/i\\
                - name: IPALLOC_RANGE\\
                  value: $NETWORK_CIDR" weave.yaml

sudo -H -u $USER bash -c "kubectl apply -f weave.yaml"

log_message "Use this command on wokrers to connect it to this k8s cluster:"
echo "sudo $(kubeadm token create --print-join-command)"






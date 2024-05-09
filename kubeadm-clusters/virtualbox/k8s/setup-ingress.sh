#!/bin/bash

MASTER_NODE_NAME=$1 # controlplane
DOMAINS=$2 # adminer.k8s.com, kanban.k8s.com
INGRESS_NGINX_CONTROLLER_VERSION=$3 # 1.10.1
USER="vagrant"

DOMAINS=$(echo "$DOMAINS" | tr -d ' ')

sudo -H -u $USER bash -c "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v${INGRESS_NGINX_CONTROLLER_VERSION}/deploy/static/provider/cloud/deploy.yaml"

# Get controleplain IP
PRIMARY_IP=$(cat /etc/hosts | grep $MASTER_NODE_NAME | awk '{ print $1 }')

# Setup for metal-base cluster
sudo -H -u $USER bash -c "kubectl patch service -n ingress-nginx ingress-nginx-controller -p '{\"spec\": {\"type\": \"LoadBalancer\", \"externalIPs\":[\"$PRIMARY_IP\"]}}'"
echo "=== Set esternal clutrer IP: $PRIMARY_IP"

sudo chown $USER /vagrant/k8s/deployment/*

# Setup /etc/hosts on VM
IFS=',' read -ra DOMAINS_ARRAY <<< "$DOMAINS"

for DOMAIN in "${DOMAINS_ARRAY[@]}"; do
    echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts >/dev/null
done

# Setup Nginx on VM
sudo apt install nginx -y
for DOMAIN in "${DOMAINS_ARRAY[@]}"; do
    sudo rm -f /etc/nginx/sites-available/$DOMAIN
    sudo rm -f /etc/nginx/sites-enabled/$DOMAIN
    echo "server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://$PRIMARY_IP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null
    sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
done

sudo systemctl restart nginx
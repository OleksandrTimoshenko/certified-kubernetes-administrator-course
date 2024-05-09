#!/bin/bash

DOMAINS=$1 # adminer.k8s.com, kanban.k8s.com
VAGRANT_PORT=$2

DOMAINS=$(echo "$DOMAINS" | tr -d ' ')
IFS=',' read -ra DOMAINS_ARRAY <<< "$DOMAINS"

sudo apt update -y
sudo apt install nginx -y

for DOMAIN in "${DOMAINS_ARRAY[@]}"; do
    sudo rm -f /etc/nginx/sites-available/$DOMAIN
    sudo rm -f /etc/nginx/sites-enabled/$DOMAIN
    echo "server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://$DOMAIN:$VAGRANT_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null
    sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
done

sudo systemctl restart nginx

for DOMAIN in "${DOMAINS_ARRAY[@]}"; do
  if grep -q "^\s*#127.0.0.1\s*$DOMAIN" /etc/hosts; then
    sudo sed -i "/^\s*#127.0.0.1\s*$DOMAIN/s/^#//" /etc/hosts
    echo "Uncommented $DOMAIN in /etc/hosts"
  elif ! grep -q "^\s*127.0.0.1\s*$DOMAIN" /etc/hosts; then
    echo "127.0.0.1 $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
  else
    echo "$DOMAIN already exists in /etc/hosts"
  fi
done
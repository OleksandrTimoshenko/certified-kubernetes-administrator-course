#!/bin/bash

USER="vagrant"

# waiting time = 10 mins
TIMEOUT=$((10 * 60))
START_TIME=$(date +%s)

while true; do
    if sudo -H -u $USER bash -c "kubectl get pods -n ingress-nginx | grep ingress-nginx-controller | grep -q '1/1     Running'"; then
        echo "Pod ingress-nginx-controller is running"
        sudo -H -u $USER bash -c "kubectl apply -f /vagrant/k8s/deployment"
        break
    else
        # check timeout
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
            echo "ERROR: Timeout: Pod ingress-nginx-controller did not start within $TIMEOUT seconds, pls check your cluster..."
            exit 1
        fi
        
        echo "Pod ingress-nginx-controller is not running yet, waiting..."
        sleep 5
    fi
done

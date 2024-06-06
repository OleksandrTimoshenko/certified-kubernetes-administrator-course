#!/bin/bash

USER="vagrant"
DEPLOY_APP_MODE=$1

# waiting time = 10 mins
TIMEOUT=$((10 * 60))
START_TIME=$(date +%s)

apply_deployment() {
    mode=$1
    case $mode in
        "default")
            echo "Applying kubectl deployment..."
            sudo -H -u $USER bash -c "kubectl apply -f /vagrant/k8s/deployment"
            ;;
        "helm-charts")
            echo "Applying helm-charts deployment..."
            sudo -H -u $USER bash -c "helm install -f /vagrant/k8s/helm/kanban-postgres.yaml postgres /vagrant/k8s/helm/postgres"
            sudo -H -u $USER bash -c "helm install -f /vagrant/k8s/helm/adminer.yaml adminer /vagrant/k8s/helm/app"
            sudo -H -u $USER bash -c "helm install -f /vagrant/k8s/helm/kanban-app.yaml kanban-app /vagrant/k8s/helm/app"
            sudo -H -u $USER bash -c "helm install -f /vagrant/k8s/helm/kanban-ui.yaml kanban-ui /vagrant/k8s/helm/app"
            #sudo -H -u $USER bash -c "helm dependency update /vagrant/k8s/helm/ingress/"
            sudo -H -u $USER bash -c "helm install -f /vagrant/k8s/helm/ingress.yaml ingress /vagrant/k8s/helm/ingress"
            ;;
        "helmfile")
            sudo -H -u $USER bash -c "helmfile repos -f /vagrant/k8s/helm/helmfile.yaml"
            sudo -H -u $USER bash -c "helmfile sync -f /vagrant/k8s/helm/helmfile.yaml"
            ;;
        *)
            echo "ERROR: Invalid DEPLOY_APP_MODE: $DEPLOY_APP_MODE"
            exit 1
            ;;
    esac
}

while true; do
    if sudo -H -u $USER bash -c "kubectl get pods -n ingress-nginx | grep ingress-nginx-controller | grep -q '1/1     Running'"; then
        echo "Pod ingress-nginx-controller is running"
        apply_deployment $DEPLOY_APP_MODE
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

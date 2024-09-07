# Create agroCD in cluster

## Creating SSL certs and secrets

1. generate SSL certs
```
cd /vagrant/
openssl genrsa -out argocd.k8s.com.key 2048
openssl req -new -x509 -key argocd.k8s.com.key -out argocd.k8s.com.crt -days 365 \
-subj "/CN=argocd.k8s.com"
```
2. create secret for SSL certs: <!--- TODO: replace it with definition + Kubernetes Secret Management Tools --->
`kubectl create secret tls argocd-tls-secret --cert=/vagrant/argocd.k8s.com.crt --key=/vagrant/argocd.k8s.com.key`
3. Copy SSL certs to host mashine (you will use it for local nginx)



## Creating k8s resources

1. create new namespace: `kubectl create namespace argocd`

2. deploy `argocd` application: 
`k apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd`
or you can use `https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml` file



## Create agrocd applications & ingress controller
`k apply -f /vagrant/k8s/argocd/`

## Get argocd pass: 
`k get secrets -n argocd argocd-initial-admin-secret -o jsonpath=""{.data.password} | base64 -d`


## Setup VM networking

1. `sudo nano /etc/nginx/sites-available/argocd.k8s.com`
- update IP in config `cat /etc/hosts | grep controlplane | awk '{ print $1 }'`
<!--- get nginx config --->

2. Reload Nginx
`sudo rm -rf /etc/nginx/sites-enabled/argocd.k8s.com && sudo ln -s /etc/nginx/sites-available/argocd.k8s.com /etc/nginx/sites-enabled/ && sudo nginx -t && sudo nginx -s reload`

3. Test: `curl -k https://argocd.k8s.com`



### Setup host networking

1. Setup nginx in host (I use SSL certs from folder)
`sudo nano /etc/nginx/sites-available/argocd.k8s.com`
- update path to SSL certs in config
<!--- get nginx-local config --->

2. Reload Nginx
`sudo rm -rf /etc/nginx/sites-enabled/argocd.k8s.com && sudo ln -s /etc/nginx/sites-available/argocd.k8s.com /etc/nginx/sites-enabled/ && sudo nginx -t && sudo nginx -s reload`

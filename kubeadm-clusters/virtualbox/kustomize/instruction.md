# install `kustomize` as binary file
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo vm ./kustomize /bin/
kustomize version
```

# build without changes
```
kustomize build ./base/ > res.yaml
```

# build for DEV
```
kustomize build ./overlays/dev/ > res-dev.yaml
```

# build for PROD
```
kustomize build ./overlays/prod/ > res-prod.yaml
```
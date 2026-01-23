# Requirements
- Vagrant (custom setup tested only with VirtualBox virtualization)
- Linux OS as host machine (perfectly Debian-based)

# Start k8s cluster deployment
<!--TODO: add .env file for start script-->
```
./start.sh
```

# Resources
## Kanban UI
http://kanban.k8s.com
## Adminer 
http://adminer.k8s.com
### Credentials
- PostgreSQL
- postgres
- kanban
- kanban
- kanban

## Swagger UI
http://kanban.k8s.com/api/swagger-ui.html#/

## ArgoCD (for now custom [setup](../../agrocd/instruction.md))
https://argocd.k8s.com/
### Credentials
- admin
- `k get secrets -n argocd argocd-initial-admin-secret -o jsonpath=""{.data.password} | base64 -d`